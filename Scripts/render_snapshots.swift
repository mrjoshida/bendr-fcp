#!/usr/bin/env swift
// render_snapshots.swift — High-fidelity functional image verification & PNG snapshot renderer for all 14 BENDR plugins

import Foundation
import Metal
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import simd

print("==================================================")
print("📸 BENDR High-Fidelity Visual Snapshot Test (1080p)")
print("==================================================")

guard let device = MTLCreateSystemDefaultDevice() else {
    print("❌ No Metal device available.")
    exit(1)
}

print("💻 Rendering on GPU: \(device.name)")

guard let commandQueue = device.makeCommandQueue() else {
    print("❌ Failed to create MTLCommandQueue.")
    exit(1)
}

let rootDir = FileManager.default.currentDirectoryPath
let outputDir = "\(rootDir)/Tests/Outputs"
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

// Load all Metal shaders
let metalSources = [
    "Shared/Metal/BendrCommon.h",
    "Shared/Metal/BendrBlends.metal",
    "BENDRVHSService/Metal/BENDRVHS.metal",
    "BENDRCRTService/Metal/BENDRCRT.metal",
    "BENDRFeedbackService/Metal/BENDRFeedback.metal",
    "BENDRColourService/Metal/BENDRColour.metal",
    "BENDRScanService/Metal/BENDRScan.metal",
    "BENDRCorruptService/Metal/BENDRCorrupt.metal",
    "BENDRMeltService/Metal/BENDRMelt.metal",
    "BENDRDirtyService/Metal/BENDRDirty.metal",
    "BENDRFlowService/Metal/BENDRFlow.metal",
    "BENDRSignalLabService/Metal/BENDRSignalLab.metal",
    "BENDRSynthService/Metal/BENDRSynth.metal",
    "BENDRTransitionService/Metal/BENDRTransition.metal",
    "BENDRSpatialService/Metal/BENDRSpatial.metal",
    "BENDROpticsService/Metal/BENDROptics.metal"
]

var combinedSource = "#include <metal_stdlib>\nusing namespace metal;\n"
for relPath in metalSources {
    let url = URL(fileURLWithPath: "\(rootDir)/\(relPath)")
    if let str = try? String(contentsOf: url, encoding: .utf8) {
        let cleaned = str.replacingOccurrences(of: "#include <metal_stdlib>", with: "")
                         .replacingOccurrences(of: "using namespace metal;", with: "")
                         .replacingOccurrences(of: "#include \"../../Shared/Metal/BendrCommon.h\"", with: "")
                         .replacingOccurrences(of: "#include \"../../Shared/Metal/BendrBlends.metal\"", with: "")
                         .replacingOccurrences(of: "#include \"BendrCommon.h\"", with: "")
        combinedSource += "\n// --- \(relPath) ---\n" + cleaned
    }
}

let compileOptions = MTLCompileOptions()
guard let library = try? device.makeLibrary(source: combinedSource, options: compileOptions) else {
    print("❌ Failed to compile unified Metal library.")
    exit(1)
}

let width = 1920
let height = 1080

let texDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
texDesc.usage = [.shaderRead, .shaderWrite]

guard let srcTex = device.makeTexture(descriptor: texDesc),
      let prevTex = device.makeTexture(descriptor: texDesc),
      let dstTex = device.makeTexture(descriptor: texDesc) else {
    print("❌ Failed to allocate 1080p textures.")
    exit(1)
}

let samplerDesc = MTLSamplerDescriptor()
samplerDesc.minFilter = .linear
samplerDesc.magFilter = .linear
guard let samplerState = device.makeSamplerState(descriptor: samplerDesc) else {
    print("❌ Failed to create sampler state.")
    exit(1)
}

// Generate SMPTE test card with colorful geometric shapes
var srcPixels = [UInt8](repeating: 0, count: width * height * 4)
var prevPixels = [UInt8](repeating: 0, count: width * height * 4)

let smpteColors: [(UInt8, UInt8, UInt8)] = [
    (200, 200, 200), // White
    (220, 200, 0),   // Yellow
    (0, 220, 220),   // Cyan
    (0, 220, 0),     // Green
    (220, 0, 220),   // Magenta
    (220, 0, 0),     // Red
    (0, 0, 220)      // Blue
]

for y in 0..<height {
    for x in 0..<width {
        let idx = (y * width + x) * 4
        let barIdx = (x * smpteColors.count) / width
        let color = smpteColors[barIdx]
        
        if y < (height * 3) / 5 {
            srcPixels[idx + 0] = color.0
            srcPixels[idx + 1] = color.1
            srcPixels[idx + 2] = color.2
        } else if y < (height * 4) / 5 {
            let subX = (x * 4) % width
            let grad = UInt8((subX * 255) / width)
            srcPixels[idx + 0] = (x < width/2) ? grad : 255 - grad
            srcPixels[idx + 1] = grad
            srcPixels[idx + 2] = (x > width/4) ? 255 - grad : grad
        } else {
            let grad = UInt8((x * 255) / width)
            srcPixels[idx + 0] = grad
            srcPixels[idx + 1] = grad
            srcPixels[idx + 2] = grad
        }
        
        // High-contrast concentric alignment rings
        let dx = Float(x - width / 2)
        let dy = Float(y - height / 2)
        let dist = sqrt(dx * dx + dy * dy)
        if abs(dist - 200.0) < 6.0 || abs(dist - 350.0) < 4.0 {
            srcPixels[idx + 0] = 255
            srcPixels[idx + 1] = 255
            srcPixels[idx + 2] = 255
        }
        
        srcPixels[idx + 3] = 255
        
        // Secondary test pattern: cyan/magenta checkerboard
        let chk = (((x / 64) ^ (y / 64)) & 1)
        let pVal: UInt8 = (chk == 1) ? 230 : 25
        prevPixels[idx + 0] = pVal
        prevPixels[idx + 1] = 255 - pVal
        prevPixels[idx + 2] = 255
        prevPixels[idx + 3] = 255
    }
}

srcTex.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: srcPixels, bytesPerRow: width * 4)
prevTex.replace(region: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0, withBytes: prevPixels, bytesPerRow: width * 4)

// PNG save helper
func savePNG(texture: MTLTexture, path: String) -> Bool {
    var pixelBytes = [UInt8](repeating: 0, count: width * height * 4)
    texture.getBytes(&pixelBytes, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    guard let provider = CGDataProvider(data: Data(pixelBytes) as CFData),
          let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
          ) else {
        return false
    }
    
    let url = URL(fileURLWithPath: path) as CFURL
    guard let destination = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else {
        return false
    }
    
    CGImageDestinationAddImage(destination, cgImage, nil)
    return CGImageDestinationFinalize(destination)
}

// Struct declarations matching Metal shaders 1-to-1

struct VHSParams {
    var chromaBleed: Float = 0.65
    var chromaDelay: Float = 0.25
    var lumaBleed: Float = 0.35
    var bleedDir: Float = 0.5
    var vBleed: Float = 0.0
    var rainbow: Float = 0.3
    var dotCrawl: Float = 0.2
    var ringing: Float = 0.25
    var signalNoise: Float = 0.15
    var chromaNoise: Float = 0.2

    var hWobble: Float = 0.15
    var wobbleFreq: Float = 0.3
    var tear: Float = 0.1
    var tearSize: Float = 0.4
    var vRoll: Float = 0.0
    var jitter: Float = 0.4
    var humBar: Float = 0.2

    var tapeSpeed: Float = 0.0
    var tracking: Float = 0.3
    var trackPhase: Float = 0.0
    var trackHunt: Float = 0.0
    var dropout: Float = 0.25
    var dropoutLen: Float = 0.35
    var chromaLoss: Float = 0.0
    var crease: Float = 0.2
    var creasePos: Float = 0.75
    var headClog: Float = 0.0
    var azimuth: Float = 0.0
    var headSwitch: Float = 0.4
    var tapeWow: Float = 0.15
    var wowRate: Float = 0.25
    var flutter: Float = 0.0
    var tapeStretch: Float = 0.0
    var edgeDmg: Float = 0.3
    var printThru: Float = 0.0
    var hiss: Float = 0.0
    var stillNoise: Float = 0.0
    var shuttleNz: Float = 0.0
    var genLoss: Float = 0.2
    var genCount: Float = 2.0

    var time: Float = 1.2
    var frame: Float = 36.0
    var rows: Float = 1080.0
    var vrollpos: Float = 0.0
    var humpos: Float = 0.2
    var rollBar: Float = 0.0
}

struct CRTParams {
    var procRes: SIMD2<Float> = SIMD2<Float>(1920, 1080)
    var scanlines: Float = 0.85
    var beamWidth: Float = 1.0
    var beamShape: Float = 0.5
    var aperture: Float = 0.65
    var maskDark: Float = 0.55
    var curvature: Float = 0.25
    var cornerRound: Float = 0.18
    var vignette: Float = 0.45
    var time: Float = 1.0
    var outModel: Float = 1.0 // 1: Aperture Grille
    var hasPersist: Float = 0.0
    var bloom: Float = 0.35
    var bloomRad: Float = 0.4
    var halation: Float = 0.35
    var defocus: Float = 0.0
    var grain: Float = 0.05
    var outGamma: Float = 1.0
    var outBright: Float = 0.0 // 0.0 offset (no blowout!)
    var outContrast: Float = 1.1
    var outSat: Float = 1.15
    var outWarmth: Float = 0.05
    var blackLevel: Float = 0.02
    var whiteClip: Float = 1.0
    var phosphor: Float = 0.0
    var hvSag: Float = 0.0
    var letterbox: Float = 0.0
    var pillarbox: Float = 0.0
    var bezel: Float = 0.0
    var glassRefl: Float = 0.2
    var dust: Float = 0.0
    var scratches: Float = 0.0
    var ovMoire: Float = 0.0
    var rollShutter: Float = 0.0
    var safeArea: Float = 0.0
    var lensDist: Float = 0.0
    var lensCA: Float = 0.0
    var lensStreak: Float = 0.0
    var streakHue: Float = 1.0
    var lensSmudge: Float = 0.0
    var lightLeak: Float = 0.0
    var leakHue: Float = 0.0
    var gateWeave: Float = 0.0
    var gateHair: Float = 0.0
    var stuckPix: Float = 0.0
    var lcdGrid: Float = 0.0
    var osdShow: Float = 0.0
    var osdGlow: Float = 0.0
    var probe: Float = 0.0
    var rows: Float = 1080.0
}

struct FeedbackParams {
    var srcAspect: Float = 1.7777
    var hasSrc: Float = 1.0
    var hasDelay: Float = 0.0
    var time: Float = 1.5
    var fbAmount: Float = 0.75
    var fbZoom: Float = 0.06
    var fbRotate: Float = 0.08
    var fbHue: Float = 0.2
    var fbShiftX: Float = 0.01
    var fbShiftY: Float = 0.005
    var fbMode: Float = 0.0
    var echo: Float = 0.0
    var srcZoom: Float = 0.0
    var srcX: Float = 0.0
    var srcY: Float = 0.0
    var srcRot: Float = 0.0
    var edgeMode: Float = 1.0 // Wrap
    var flipMode: Float = 0.0
    var mirrorMode: Float = 0.0
    var multiN: Float = 1.0
    var shakeX: Float = 0.0
    var shakeY: Float = 0.0
    var kaleido: Float = 0.0
    var kaleidoN: Float = 4.0
    var kaleidoRot: Float = 0.0
    var kaleidoX: Float = 0.0
    var kaleidoY: Float = 0.0
    var fbShearX: Float = 0.0
    var fbShearY: Float = 0.0
    var fbGainR: Float = 1.0
    var fbGainG: Float = 1.0
    var fbGainB: Float = 1.0
    var fbSat: Float = 1.1
    var fbVal: Float = 1.0
    var fbPost: Float = 0.0
    var fbChromOff: Float = 0.0
    var fbBlur: Float = 0.0
    var fbBlur2: Float = 0.0
    var fbSharp: Float = 0.0
    var fbDrive: Float = 1.0
    var fbPivot: Float = 0.5
    var fbThresh: Float = 0.0
    var fbThreshSoft: Float = 0.0
    var fbNoise: Float = 0.0
    var fbNoiseScale: Float = 1.0
    var fbRoll: Float = 0.0
    var fbJitter: Float = 0.0
    var fbWrap: Float = 1.0
    var fbMirror: Float = 0.0
    var fbBlend: Float = 0.0 // Mix
    var fbNL: Float = 0.0
    var fbInvert: Float = 0.0
    var autoGain: Float = 1.0
    var fbFlip: Float = 0.0
    var generationCount: UInt32 = 8
}

struct ColourParams {
    var rGain: Float = 1.1
    var gGain: Float = 0.9
    var bGain: Float = 1.2
    var saturation: Float = 1.3
    var hue: Float = 0.05
    var brightness: Float = 0.0
    var contrast: Float = 1.15
    var posterize: Float = 0.5
    var solarize: Float = 0.6
    var negative: Float = 0.0
    var negMode: Float = 0.0
    var monoCol: Float = 0.0
    var monoHue: Float = 0.55
    var colorPass: Float = 0.0
    var passHue: Float = 0.0
    var passWidth: Float = 0.25
    var silhouette: Float = 0.0
    var silThresh: Float = 0.45
    var silHue: Float = 0.08
    var glow: Float = 0.35
    var findEdge: Float = 0.4
    var edgeHue: Float = 0.45
    var emboss: Float = 0.0
    var embossDir: Float = 0.12
    var diffAmt: Float = 0.4
    var diffScale: Float = 0.3
    var diffPolar: Float = 0.0
    var ampAmt: Float = 0.0
    var ampBands: Float = 0.5
    var ampPick: Float = 0.0
    var ampCol: Float = 0.0
    var fgPos: Float = 0.0
    var fgNeg: Float = 0.0
    var fgZero: Float = 0.0
    var colorize: Float = 0.4
    var colorBands: Float = 3.0
    var colorSweep: Float = 0.2
    var lumaHue: Float = 0.0
    var sharpEcho: Float = 0.0
    var echoSpace: Float = 0.3
    var rgbSep: Float = 0.6
    var invFlick: Float = 0.0
    var contour: Float = 0.5
    var contourBands: Float = 8.0
    var contourWidth: Float = 1.5
    var contourHue: Float = 0.3
    var contourFill: Float = 0.4
    var lumaSteps: Float = 0.0
    var stepCount: Float = 5.0
    var dither: Float = 0.0
    var mline: Float = 0.0
    var mlineScale: Float = 1.0
    var mlineGain: Float = 1.15
    var mlineBias: Float = 0.0
    var mlineFb: Float = 0.92
    var mlineWin: Float = 32.0
    var mlineTint: Float = 0.0
    var mlineCol: Float = 0.0
    var mlineSerp: Float = 1.0
    var time: Float = 1.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct ScanParams {
    var lines: Float = 120.0
    var samples: Float = 256.0
    var scanAmt: Float = 0.65
    var scanWidth: Float = 0.35
    var scanVel: Float = 0.8
    var scanTiltX: Float = 0.15
    var scanTiltY: Float = 0.25
    var scanPersp: Float = 0.4
    var scanCurve: Float = 0.2
    var scanCollapse: Float = 0.0
    var scanRevH: Float = 0.0
    var scanRevV: Float = 0.0
    var scanWobAmt: Float = 0.35
    var scanWobFreq: Float = 0.4
    var scanWobLock: Float = 1.0
    var scanLissa: Float = 0.2
    var scanSkew: Float = 0.1
    var scanGain: Float = 1.2
    var scanMono: Float = 0.0
    var scanHue: Float = 0.0
    var time: Float = 1.0
}

struct CorruptParams {
    var pixelSort: Float = 0.85
    var sortThresh: Float = 0.4
    var blockShift: Float = 0.6
    var blockSize: Float = 0.35
    var dotify: Float = 0.0
    var dotSize: Float = 0.4
    var driftWarp: Float = 0.3
    var fmWarp: Float = 0.25
    var dctAmt: Float = 0.75
    var dctQ: Float = 0.35
    var dctTilt: Float = 0.5
    var dctChroma: Float = 0.6
    var dctBlock: Float = 0.4
    var time: Float = 1.5
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct MeltParams {
    var meltMode: Float = 3.0 // 3: Gravity Melt
    var edgeAmt: Float = 1.6  // Melt drift distance
    var edgeHold: Float = 0.95
    var edgeWidth: Float = 0.4
    var edgeCreep: Float = 0.75
    var edgeSwirl: Float = 0.2
    var meltZoom: Float = 0.0
    var meltDir: Float = 0.0 // Straight down gravity
    var meltGate: Float = 0.0
    var meltSoft: Float = 0.3
    var edgeChroma: Float = 0.85
    var meltHue: Float = 0.15
    var time: Float = 1.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct DirtyParams {
    var mixDirt: Float = 0.95
    var mixDirtRate: Float = 0.8
    var mixDirtKnock: Float = 0.75
    var mixDirtDrop: Float = 0.7
    var mixDirtCut: Float = 0.4
    var mixDirtNoise: Float = 0.5
    var time: Float = 2.4
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct FlowParams {
    var flowField: Float = 2.0 // Curl Noise
    var moshVec: Float = 0.85
    var flowGain: Float = 1.8
    var flowCurl: Float = 0.7
    var flowEdge: Float = 1.0 // Wrap
    var mosh: Float = 0.3
    var moshGate: Float = 0.0
    var timeGrad: Float = 0.0
    var shearAxis: Float = 0.0
    var melt: Float = 0.5
    var meltDir: Float = 0.0
    var meltGate: Float = 0.0
    var swirl: Float = 0.6
    var swirlScale: Float = 0.35
    var swirlSpeed: Float = 0.2
    var moshBlock: Float = 0.35
    var moshBlockSize: Float = 0.5
    var moshRate: Float = 0.25
    var flowStretch: Float = 0.0
    var flowRepel: Float = 0.0
    var flowNoise: Float = 0.25
    var flowSharp: Float = 0.35
    var flowHue: Float = 0.1
    var flowFade: Float = 0.02
    var time: Float = 1.5
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct SignalLabParams {
    var sparseJit: Float = 0.65
    var jitThresh: Float = 0.55
    var fmAmt: Float = 0.75
    var fmCarrier: Float = 0.4
    var slitscan: Float = 0.5
    var slitDir: Float = 0.0
    var rowSmear: Float = 0.4
    var pngAmt: Float = 0.7
    var pngDir: Float = 0.0
    var pngRun: Float = 0.5
    var ntscArt: Float = 0.8
    var ntscFringe: Float = 0.6
    var snow: Float = 0.3
    var snowAniso: Float = 0.5
    var moire: Float = 0.5
    var moireFreq: Float = 0.6
    var bitCrush: Float = 0.85
    var bitScale: Float = 0.4
    var bandKey: Float = 0.0
    var bandN: Float = 5.0
    var bandHue: Float = 0.3
    var fieldMod: Float = 0.5
    var fieldSrc: Float = 2.0 // Radial
    var fieldWarp: Float = 0.4
    var fieldHue: Float = 0.3
    var time: Float = 1.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct SynthParams {
    var shape: Float = 6.0 // Starburst
    var wave: Float = 0.0  // Sine
    var colmode: Float = 2.0 // HSV Spectrum
    var genFreqX: Float = 0.2
    var genFreqY: Float = 0.2
    var genPhase: Float = 0.0
    var genRate: Float = 0.1
    var genRot: Float = 0.0
    var genSkew: Float = 0.0
    var genFM: Float = 0.45
    var genPulse: Float = 0.5
    var genFold: Float = 0.6
    var genComp: Float = 0.0
    var genThresh: Float = 0.5
    var genSoft: Float = 0.12
    var genFoldN: Float = 8.0 // 8-point star
    var genCX: Float = 0.0
    var genCY: Float = 0.0
    var genZoom: Float = 0.0
    var genWarp: Float = 0.3
    var genHue: Float = 0.55
    var genSpread: Float = 1.2
    var genSat: Float = 0.95
    var genBright: Float = 1.1
    var genBands: Float = 8.0
    var blendWithSource: Float = 0.0
    var time: Float = 1.5
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct TransitionParams {
    var abMix: Float = 0.5         // 50% midpoint wipe
    var mixMode: Float = 10.0      // 10: Clock Wipe
    var mixBlend: Float = 0.0      // 0: Normal
    var wipeSoft: Float = 0.03
    var wipeDetail: Float = 0.3
    var wipeX: Float = 0.0
    var wipeY: Float = 0.0
    var wipeInv: Float = 0.0
    var wipeBord: Float = 0.75     // Highlighted border line
    var wipeBordCol: Float = 0.5   // Magenta border
    var wipeRep: Float = 1.0
    var mixKey: Float = 0.0
    var mixKeyThresh: Float = 0.5
    var mixKeySoft: Float = 0.2
    var mixKeyHue: Float = 0.33
    var mixKeyInv: Float = 0.0
    var mixKeyGain: Float = 0.5
    var mixKeyDens: Float = 1.0
    var mixKeyEdge: Float = 0.0
    var mixKeyEdgeCol: Float = 0.0
    var mixKeyShadow: Float = 0.0
    var time: Float = 1.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct SpatialParams {
    var srcZoom: Float = 0.15
    var srcX: Float = 0.0
    var srcY: Float = 0.0
    var srcRot: Float = 0.08
    var flipMode: Float = 0.0
    var mirrorMode: Float = 0.0
    var multiN: Float = 1.0
    var kaleido: Float = 1.0 // 6-fold kaleidoscope
    var kaleidoN: Float = 6.0
    var kaleidoRot: Float = 0.15
    var kaleidoX: Float = 0.0
    var kaleidoY: Float = 0.0
    var shake: Float = 0.0
    var shakeRate: Float = 1.0
    var tdAmt: Float = 0.6 // Time displace
    var tdMap: Float = 2.0 // Luma Map
    var tdSpread: Float = 0.7
    var tdSoft: Float = 1.0
    var tdWarp: Float = 0.2
    var time: Float = 1.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

struct OpticsParams {
    var lensCA: Float = 0.75
    var lensStreak: Float = 0.85
    var streakHue: Float = 0.6 // Blue coating
    var bloom: Float = 0.65
    var bloomRad: Float = 0.35
    var halation: Float = 0.75
    var vignette: Float = 0.5
    var lensSmudge: Float = 0.6
    var lightLeak: Float = 0.55
    var leakHue: Float = 0.08
    var gateHair: Float = 0.0
    var dust: Float = 0.3
    var scratches: Float = 0.4
    var grain: Float = 0.25
    var lcdGrid: Float = 0.0
    var osdShow: Float = 1.0 // Camcorder HUD
    var osdMode: Float = 0.0
    var osdGlow: Float = 0.7
    var time: Float = 14.8
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

// Rigorous visual verification function analyzing the rendered buffer
func analyzePixels(name: String, px: [UInt8], srcPx: [UInt8]) -> (Bool, String) {
    var nonZeroCount = 0
    var diffCount = 0
    var totalLuma: Double = 0
    var minVal: UInt8 = 255
    var maxVal: UInt8 = 0
    
    let pixelCount = width * height
    for i in 0..<pixelCount {
        let idx = i * 4
        let r = px[idx + 0]
        let g = px[idx + 1]
        let b = px[idx + 2]
        
        if r > 5 || g > 5 || b > 5 {
            nonZeroCount += 1
        }
        
        let sr = srcPx[idx + 0]
        let sg = srcPx[idx + 1]
        let sb = srcPx[idx + 2]
        
        if abs(Int(r) - Int(sr)) > 8 || abs(Int(g) - Int(sg)) > 8 || abs(Int(b) - Int(sb)) > 8 {
            diffCount += 1
        }
        
        let luma = Double(r) * 0.299 + Double(g) * 0.587 + Double(b) * 0.114
        totalLuma += luma
        if r < minVal { minVal = r }
        if r > maxVal { maxVal = r }
    }
    
    let avgLuma = totalLuma / Double(pixelCount)
    let nonZeroRatio = Double(nonZeroCount) / Double(pixelCount)
    let diffRatio = Double(diffCount) / Double(pixelCount)
    
    if nonZeroRatio < 0.5 {
        return (false, "FAILED: Image is mostly BLACK (only \(Int(nonZeroRatio * 100))% active pixels, avg luma: \(Int(avgLuma)))")
    }
    
    if name != "BENDR_Synth" && diffRatio < 0.05 {
        return (false, "FAILED: No visible effect (diff ratio: \(Int(diffRatio * 100))%)")
    }
    
    if (maxVal - minVal) < 40 {
        return (false, "FAILED: Flat single-color output (range: \(minVal)..\(maxVal))")
    }
    
    return (true, "Active: \(Int(nonZeroRatio * 100))%, Mod: \(Int(diffRatio * 100))%, Dynamic Range: \(minVal)..\(maxVal)")
}

let runners: [(name: String, kernel: String, category: String, execute: (MTLComputeCommandEncoder) -> Void)] = [
    ("BENDR_VHS", "bendrVHS", "single", { enc in
        var p = VHSParams()
        enc.setBytes(&p, length: MemoryLayout<VHSParams>.stride, index: 0)
    }),
    ("BENDR_CRT", "bendrCRT", "crt", { enc in
        var p = CRTParams()
        enc.setBytes(&p, length: MemoryLayout<CRTParams>.stride, index: 0)
    }),
    ("BENDR_Feedback", "bendrFeedback", "feedback", { enc in
        var p = FeedbackParams()
        enc.setBytes(&p, length: MemoryLayout<FeedbackParams>.stride, index: 0)
    }),
    ("BENDR_Colour", "bendrColour", "single", { enc in
        var p = ColourParams()
        enc.setBytes(&p, length: MemoryLayout<ColourParams>.stride, index: 0)
    }),
    ("BENDR_Scan", "bendrScan", "single", { enc in
        var p = ScanParams()
        enc.setBytes(&p, length: MemoryLayout<ScanParams>.stride, index: 0)
    }),
    ("BENDR_Corrupt", "bendrCorrupt", "single", { enc in
        var p = CorruptParams()
        enc.setBytes(&p, length: MemoryLayout<CorruptParams>.stride, index: 0)
    }),
    ("BENDR_Melt", "bendrMelt", "melt", { enc in
        var p = MeltParams()
        enc.setBytes(&p, length: MemoryLayout<MeltParams>.stride, index: 0)
    }),
    ("BENDR_Dirty", "bendrDirty", "single", { enc in
        var p = DirtyParams()
        enc.setBytes(&p, length: MemoryLayout<DirtyParams>.stride, index: 0)
    }),
    ("BENDR_Flow", "bendrFlow", "flow", { enc in
        var p = FlowParams()
        enc.setBytes(&p, length: MemoryLayout<FlowParams>.stride, index: 0)
    }),
    ("BENDR_SignalLab", "bendrSignalLab", "single", { enc in
        var p = SignalLabParams()
        enc.setBytes(&p, length: MemoryLayout<SignalLabParams>.stride, index: 0)
    }),
    ("BENDR_Synth", "bendrSynth", "single", { enc in
        var p = SynthParams()
        enc.setBytes(&p, length: MemoryLayout<SynthParams>.stride, index: 0)
    }),
    ("BENDR_Transition", "bendrTransition", "transition", { enc in
        var p = TransitionParams()
        enc.setBytes(&p, length: MemoryLayout<TransitionParams>.stride, index: 0)
    }),
    ("BENDR_Spatial", "bendrSpatial", "spatial", { enc in
        var p = SpatialParams()
        enc.setBytes(&p, length: MemoryLayout<SpatialParams>.stride, index: 0)
    }),
    ("BENDR_Optics", "bendrOptics", "single", { enc in
        var p = OpticsParams()
        enc.setBytes(&p, length: MemoryLayout<OpticsParams>.stride, index: 0)
    }),
    // Curated Presets Verification
    ("BENDR_VHS_ChewedTape", "bendrVHS", "single", { enc in
        var p = VHSParams()
        p.tracking = 0.55
        p.trackHunt = 0.6
        p.crease = 0.6
        p.dropout = 0.5
        p.chromaLoss = 0.4
        p.hiss = 0.3
        p.genLoss = 0.35
        p.tapeWow = 0.35
        p.chromaBleed = 0.45
        enc.setBytes(&p, length: MemoryLayout<VHSParams>.stride, index: 0)
    }),
    ("BENDR_CRT_ArcadeSlotMask", "bendrCRT", "crt", { enc in
        var p = CRTParams()
        p.outModel = 2.0
        p.scanlines = 0.65
        p.maskDark = 0.6
        p.curvature = 0.2
        p.bloom = 0.4
        enc.setBytes(&p, length: MemoryLayout<CRTParams>.stride, index: 0)
    }),
    ("BENDR_Feedback_DrosteTunnel", "bendrFeedback", "feedback", { enc in
        var p = FeedbackParams()
        p.fbAmount = 0.9
        p.fbZoom = 0.2
        p.fbBlur = 0.06
        p.fbNoise = 0.05
        p.fbWrap = 1.0
        p.fbNL = 1.0
        enc.setBytes(&p, length: MemoryLayout<FeedbackParams>.stride, index: 0)
    }),
    ("BENDR_Colour_RainbowRite", "bendrColour", "single", { enc in
        var p = ColourParams()
        p.colorize = 0.85
        p.colorBands = 1.8
        p.colorSweep = 0.25
        p.saturation = 1.3
        p.glow = 0.45
        p.contrast = 1.15
        enc.setBytes(&p, length: MemoryLayout<ColourParams>.stride, index: 0)
    }),
    ("BENDR_Melt_GravityDrip", "bendrMelt", "melt", { enc in
        var p = MeltParams()
        p.meltMode = 3.0
        p.edgeAmt = 1.6
        p.edgeHold = 0.92
        p.edgeWidth = 0.4
        p.edgeCreep = 0.8
        p.edgeChroma = 0.85
        p.meltHue = 0.15
        enc.setBytes(&p, length: MemoryLayout<MeltParams>.stride, index: 0)
    }),
    ("BENDR_Flow_CurlNoise", "bendrFlow", "flow", { enc in
        var p = FlowParams()
        p.flowField = 2.0
        p.moshVec = 0.85
        p.flowGain = 1.8
        p.flowCurl = 0.7
        p.flowEdge = 1.0
        p.mosh = 0.3
        enc.setBytes(&p, length: MemoryLayout<FlowParams>.stride, index: 0)
    }),
    ("BENDR_Synth_SpiralDrive", "bendrSynth", "single", { enc in
        var p = SynthParams()
        p.shape = 2.0
        p.wave = 1.0
        p.colmode = 2.0
        p.genFreqX = 0.3
        p.genFoldN = 6.0
        p.genRate = 0.12
        p.genSpread = 1.5
        p.genHue = 0.1
        p.genSat = 1.0
        p.genFold = 0.25
        enc.setBytes(&p, length: MemoryLayout<SynthParams>.stride, index: 0)
    }),
    ("BENDR_Spatial_80sTriangle", "bendrSpatial", "spatial", { enc in
        var p = SpatialParams()
        p.kaleido = 1.0
        p.kaleidoN = 3.0
        p.kaleidoRot = 0.15
        p.srcZoom = 0.15
        enc.setBytes(&p, length: MemoryLayout<SpatialParams>.stride, index: 0)
    }),
    ("BENDR_Optics_CamcorderHUD", "bendrOptics", "single", { enc in
        var p = OpticsParams()
        p.osdShow = 1.0
        p.osdGlow = 0.7
        p.lensCA = 0.4
        p.vignette = 0.4
        p.grain = 0.2
        enc.setBytes(&p, length: MemoryLayout<OpticsParams>.stride, index: 0)
    })
]

var passCount = 0
var failCount = 0

print("\n--- Executing 1080p GPU Render Passes with Strict Image Quality Analysis ---")

for r in runners {
    print("  Testing \(r.name)... ", terminator: "")
    fflush(stdout)
    
    guard let function = library.makeFunction(name: r.kernel) else {
        print("❌ KERNEL NOT FOUND")
        failCount += 1
        continue
    }
    
    do {
        let pipeline = try device.makeComputePipelineState(function: function)
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            print("❌ ENCODER FAILED")
            failCount += 1
            continue
        }
        
        encoder.setComputePipelineState(pipeline)
        encoder.setSamplerState(samplerState, index: 0)
        
        if r.category == "feedback" {
            encoder.setTexture(srcTex, index: 0)
            // Use srcTex as the base for history frames to generate recursive camera-tunnel feedback
            let histTextures = [MTLTexture](repeating: srcTex, count: 16)
            encoder.setTextures(histTextures, range: 1..<17)
            encoder.setTexture(srcTex, index: 17)
            encoder.setTexture(dstTex, index: 18)
        } else if r.category == "flow" {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(srcTex, index: 1)
            encoder.setTexture(srcTex, index: 2)
            encoder.setTexture(dstTex, index: 3)
        } else if r.category == "transition" {
            // Source A = Color Bars, Source B = Checkerboard
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(prevTex, index: 1)
            encoder.setTexture(dstTex, index: 2)
        } else if r.category == "melt" {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(srcTex, index: 1)
            encoder.setTexture(dstTex, index: 2)
        } else if r.category == "crt" || r.category == "spatial" {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(prevTex, index: 1)
            encoder.setTexture(dstTex, index: 2)
        } else {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(dstTex, index: 1)
        }
        
        r.execute(encoder)
        
        let threadgroupSize = MTLSize(width: min(pipeline.maxTotalThreadsPerThreadgroup, 16), height: 16, depth: 1)
        let threadgroups = MTLSize(
            width: (width + threadgroupSize.width - 1) / threadgroupSize.width,
            height: (height + threadgroupSize.height - 1) / threadgroupSize.height,
            depth: 1
        )
        
        encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        if let err = commandBuffer.error {
            print("❌ GPU TRAP: \(err.localizedDescription)")
            failCount += 1
            continue
        }
        
        let pngPath = "\(outputDir)/\(r.name).png"
        let saved = savePNG(texture: dstTex, path: pngPath)
        
        var readPixels = [UInt8](repeating: 0, count: width * height * 4)
        dstTex.getBytes(&readPixels, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        let (ok, desc) = analyzePixels(name: r.name, px: readPixels, srcPx: srcPixels)
        if ok && saved {
            print("✅ PASSED (\(desc))")
            passCount += 1
        } else {
            print("❌ \(desc)")
            failCount += 1
        }
    } catch {
        print("❌ PIPELINE ERROR: \(error)")
        failCount += 1
    }
}

print("==================================================")
print("Visual Verification Summary: \(passCount)/\(runners.count) PASSED")
print("Rendered PNG Snapshots Saved to: \(outputDir)")
print("==================================================")

if failCount > 0 {
    exit(1)
}
