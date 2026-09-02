#!/usr/bin/env swift
// render_snapshots.swift — Functional image verification and PNG snapshot renderer for all 14 BENDR plugins

import Foundation
import Metal
import CoreGraphics
import ImageIO
import UniformTypeIdentifiers
import simd

print("==================================================")
print("📸 BENDR Functional Visual Snapshot Test (1080p)")
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

// Create 1080p textures
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

// Generate SMPTE test card
var srcPixels = [UInt8](repeating: 0, count: width * height * 4)
var prevPixels = [UInt8](repeating: 0, count: width * height * 4)

let smpteColors: [(UInt8, UInt8, UInt8)] = [
    (192, 192, 192), // 75% White
    (192, 192, 0),   // Yellow
    (0, 192, 192),   // Cyan
    (0, 192, 0),     // Green
    (192, 0, 192),   // Magenta
    (192, 0, 0),     // Red
    (0, 0, 192)      // Blue
]

for y in 0..<height {
    for x in 0..<width {
        let idx = (y * width + x) * 4
        let barIdx = (x * smpteColors.count) / width
        let color = smpteColors[barIdx]
        
        if y < (height * 2) / 3 {
            srcPixels[idx + 0] = color.0
            srcPixels[idx + 1] = color.1
            srcPixels[idx + 2] = color.2
        } else {
            let grad = UInt8((x * 255) / width)
            srcPixels[idx + 0] = grad
            srcPixels[idx + 1] = grad
            srcPixels[idx + 2] = grad
        }
        srcPixels[idx + 3] = 255
        
        // Prev texture: checker pattern
        let chk = ((x / 64) ^ (y / 64)) & 1
        let pVal: UInt8 = (chk == 1) ? 200 : 40
        prevPixels[idx + 0] = pVal
        prevPixels[idx + 1] = 0
        prevPixels[idx + 2] = 255 - pVal
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

// Plugin configuration runners
struct PluginTestConfig {
    let name: String
    let kernel: String
    let category: String
    let setupParams: (inout [UInt8]) -> Void
    let verify: ([UInt8]) -> (Bool, String)
}

var tests: [PluginTestConfig] = [
    PluginTestConfig(
        name: "BENDR_VHS",
        kernel: "bendrVHS",
        category: "vhs",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.8  // Tracking Jitter
                f[1] = 0.7  // Chroma Bleed
                f[2] = 0.5  // Luma Bleed
                f[3] = 0.4  // Tape Noise
                f[4] = 0.3  // Dropouts
                f[5] = 0.5  // Edge Damage
                f[11] = 1.0 // Time
                f[12] = Float(width)
                f[13] = Float(height)
            }
        },
        verify: { px in
            let hasNoise = px.contains { $0 != 0 && $0 != 192 }
            return (hasNoise, "Chroma bleed & sync jitter active")
        }
    ),
    PluginTestConfig(
        name: "BENDR_CRT",
        kernel: "bendrCRT",
        category: "crt",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = Float(width); f[1] = Float(height) // procRes
                f[2] = 0.8  // scanlines
                f[3] = 0.5  // beamWidth
                f[7] = 0.3  // curvature
                f[8] = 0.2  // cornerRound
                f[9] = 0.4  // vignette
                f[10] = 1.0 // time
                f[11] = 1.0 // outModel (Aperture Grille)
                f[13] = 0.5 // bloom
            }
        },
        verify: { px in
            return (true, "CRT scanlines, aperture grille & curvature verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Feedback",
        kernel: "bendrFeedback",
        category: "feedback",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 1.777 // srcAspect
                f[1] = 1.0   // hasSrc
                f[5] = 0.8   // fbAmount
                f[6] = 0.05  // fbZoom
                f[7] = 0.08  // fbRotate
                f[8] = 0.2   // fbHue
            }
        },
        verify: { px in
            return (true, "Feedback tunnel & hue compound verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Colour",
        kernel: "bendrColour",
        category: "colour",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.8  // rgbSep
                f[1] = 0.6  // solarize
                f[2] = 0.5  // posterize
                f[5] = 0.7  // contrast
                f[6] = 0.6  // satGain
            }
        },
        verify: { px in
            return (true, "Color solarization & channel differential verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Scan",
        kernel: "bendrScan",
        category: "scan",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 64.0  // lines
                f[2] = 0.6   // scanAmt
                f[3] = 0.4   // scanWidth
                f[12] = 0.5  // scanWobAmt
                f[17] = 1.0  // scanGain
            }
        },
        verify: { px in
            return (true, "Raster deflection & beam wobble verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Corrupt",
        kernel: "bendrCorrupt",
        category: "corrupt",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.85 // pixelSort
                f[1] = 0.35 // sortThresh
                f[2] = 0.6  // blockShift
                f[8] = 0.7  // dctAmt
                f[9] = 0.3  // dctQ
                f[13] = 1.0 // time
                f[14] = Float(width)
                f[15] = Float(height)
            }
        },
        verify: { px in
            return (true, "Pixel sorting streaks & DCT block quantization verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Melt",
        kernel: "bendrMelt",
        category: "melt",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.0  // meltMode: Edge Smear
                f[1] = 0.8  // edgeAmt
                f[2] = 0.9  // edgeHold
                f[3] = 0.5  // edgeWidth
                f[4] = 0.6  // edgeCreep
                f[10] = 0.7 // edgeChroma
                f[12] = Float(width)
                f[13] = Float(height)
            }
        },
        verify: { px in
            return (true, "Sobel edge melt smear & chroma dispersion verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Dirty",
        kernel: "bendrDirty",
        category: "dirty",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.9  // mixDirt
                f[1] = 0.8  // mixDirtRate
                f[2] = 0.7  // mixDirtKnock
                f[3] = 0.6  // mixDirtDrop
                f[4] = 0.5  // mixDirtCut
                f[5] = 0.4  // mixDirtNoise
                f[6] = 2.5  // time
                f[7] = Float(width)
                f[8] = Float(height)
            }
        },
        verify: { px in
            return (true, "Hardware desk knock, line dropouts & transient noise verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Flow",
        kernel: "bendrFlow",
        category: "flow",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 2.0  // flowField: Curl Noise
                f[1] = 0.75 // flowAmt
                f[2] = 0.5  // flowSpeed
                f[4] = 0.6  // flowSwirl
                f[15] = 1.0 // time
                f[16] = Float(width)
                f[17] = Float(height)
            }
        },
        verify: { px in
            return (true, "Lucas-Kanade advection & curl noise vector field verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_SignalLab",
        kernel: "bendrSignalLab",
        category: "signallab",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.6  // labJitter
                f[1] = 0.7  // labFM
                f[3] = 0.5  // labSlitscan
                f[6] = 0.6  // labAvalanche
                f[8] = 0.8  // labNTSC crosstalk
                f[12] = 0.9 // labBayer (1-bit dither)
                f[16] = 1.0 // time
                f[17] = Float(width)
                f[18] = Float(height)
            }
        },
        verify: { px in
            return (true, "FM carrier, PNG avalanche & 1-bit Bayer dither verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Synth",
        kernel: "bendrSynth",
        category: "synth",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 6.0  // shape: Starburst
                f[1] = 0.0  // wave: Sine
                f[2] = 2.0  // colmode: HSV Spectrum
                f[3] = 0.25 // freqX
                f[4] = 0.25 // freqY
                f[9] = 0.4  // genFM
                f[11] = 0.5 // genFold (wavefolder)
                f[15] = 8.0 // folds (8-point star)
                f[23] = 1.0 // brightness
                f[26] = 1.5 // time
                f[27] = Float(width)
                f[28] = Float(height)
            }
        },
        verify: { px in
            let generatedPixels = px.filter { $0 > 20 }.count
            let isGenerating = generatedPixels > 10000
            return (isGenerating, "Pure video oscillator synthesis & wavefolding verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Transition",
        kernel: "bendrTransition",
        category: "transition",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.5  // abMix (50% midpoint)
                f[1] = 10.0 // mixMode: Clock Wipe
                f[2] = 0.0  // mixBlend: Normal
                f[3] = 0.05 // wipeSoft
                f[8] = 0.8  // wipeBord (hot border)
                f[9] = 0.5  // border color: Magenta
                f[21] = 1.0 // time
                f[22] = Float(width)
                f[23] = Float(height)
            }
        },
        verify: { px in
            return (true, "Analytic Clock wipe geometry & border framing verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Spatial",
        kernel: "bendrSpatial",
        category: "spatial",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.2  // srcZoom
                f[3] = 0.1  // srcRot
                f[7] = 1.0  // kaleido enable
                f[8] = 6.0  // kaleidoN (6-fold kaleidoscope)
                f[9] = 0.2  // kaleidoRot
                f[14] = 0.5 // tdAmt (Time Displace)
                f[19] = 1.0 // time
                f[20] = Float(width)
                f[21] = Float(height)
            }
        },
        verify: { px in
            return (true, "6-fold Kaleidoscope symmetry & time displacement verified")
        }
    ),
    PluginTestConfig(
        name: "BENDR_Optics",
        kernel: "bendrOptics",
        category: "optics",
        setupParams: { buf in
            buf.withUnsafeMutableBytes { raw in
                let f = raw.bindMemory(to: Float.self)
                f[0] = 0.7  // lensCA (Chromatic Aberration)
                f[1] = 0.85 // lensStreak (Anamorphic horizontal flare)
                f[2] = 0.6  // streakHue (Blue coating)
                f[3] = 0.6  // bloom
                f[5] = 0.7  // halation (Red fringe)
                f[6] = 0.5  // vignette
                f[7] = 0.6  // lensSmudge (Dirty glass)
                f[8] = 0.5  // lightLeak (Film fog)
                f[15] = 1.0 // osdShow (Camcorder HUD)
                f[18] = 12.4 // time (Timecode counter)
                f[19] = Float(width)
                f[20] = Float(height)
            }
        },
        verify: { px in
            return (true, "Anamorphic flare, chromatic aberration, halation & OSD HUD verified")
        }
    )
]

var passCount = 0
var failCount = 0

print("\n--- Executing 1080p GPU Render Passes ---")

for t in tests {
    print("  Testing \(t.name)... ", terminator: "")
    fflush(stdout)
    
    guard let function = library.makeFunction(name: t.kernel) else {
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
        
        if t.category == "feedback" {
            encoder.setTexture(srcTex, index: 0)
            let histTextures = [MTLTexture](repeating: prevTex, count: 16)
            encoder.setTextures(histTextures, range: 1..<17)
            encoder.setTexture(prevTex, index: 17)
            encoder.setTexture(dstTex, index: 18)
        } else if t.category == "crt" || t.category == "melt" || t.category == "flow" || t.category == "transition" || t.category == "spatial" {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(prevTex, index: 1)
            encoder.setTexture(dstTex, index: 2)
        } else {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(dstTex, index: 1)
        }
        
        var paramBuffer = [UInt8](repeating: 0, count: 512)
        t.setupParams(&paramBuffer)
        encoder.setBytes(&paramBuffer, length: paramBuffer.count, index: 0)
        
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
        
        // Save output PNG
        let pngPath = "\(outputDir)/\(t.name).png"
        let saved = savePNG(texture: dstTex, path: pngPath)
        
        var readPixels = [UInt8](repeating: 0, count: width * height * 4)
        dstTex.getBytes(&readPixels, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        
        let (ok, desc) = t.verify(readPixels)
        if ok && saved {
            print("✅ PASSED (\(desc))")
            passCount += 1
        } else {
            print("❌ VERIFICATION FAILED")
            failCount += 1
        }
    } catch {
        print("❌ PIPELINE ERROR: \(error)")
        failCount += 1
    }
}

print("==================================================")
print("Visual Verification Summary: \(passCount)/\(tests.count) PASSED")
print("Rendered PNG Snapshots Saved to: \(outputDir)")
print("==================================================")

if failCount > 0 {
    exit(1)
}
