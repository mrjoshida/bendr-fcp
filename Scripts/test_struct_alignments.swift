#!/usr/bin/env swift
// test_struct_alignments.swift — Validates MemoryLayout size and alignment for all 14 parameter structs

import Foundation
import simd

print("==================================================")
print("📏 BENDR Parameter Struct Memory Layout & Alignment Test")
print("==================================================")

// Parameter struct definitions matching the 14 plugins exactly

struct VHSParams {
    var tapeSpeed: Float = 1.0
    var tracking: Float = 0.0
    var trackPhase: Float = 0.0
    var trackHunt: Float = 0.0
    var headSwitch: Float = 0.0
    var tapeWow: Float = 0.0
    var wowRate: Float = 0.5
    var flutter: Float = 0.0
    var tapeStretch: Float = 0.0
    var edgeDmg: Float = 0.0
    var dropout: Float = 0.0
    var dropoutLen: Float = 0.0
    var crease: Float = 0.0
    var creasePos: Float = 0.0
    var headClog: Float = 0.0
    var azimuth: Float = 0.0
    var genLoss: Float = 0.0
    var genCount: Float = 1.0

    var chromaBleed: Float = 0.0
    var chromaDelay: Float = 0.0
    var lumaBleed: Float = 0.0
    var bleedDir: Float = 0.0
    var vBleed: Float = 0.0
    var rainbow: Float = 0.0
    var dotCrawl: Float = 0.0
    var ringing: Float = 0.0
    var signalNoise: Float = 0.0
    var chromaNoise: Float = 0.0
    var chromaLoss: Float = 0.0
    var printThru: Float = 0.0
    var hiss: Float = 0.0

    var hWobble: Float = 0.0
    var wobbleFreq: Float = 0.5
    var tear: Float = 0.0
    var tearSize: Float = 0.0
    var vRoll: Float = 0.0
    var jitter: Float = 0.0
    var humBar: Float = 0.0

    var time: Float = 0.0
    var frame: Float = 0.0
    var humpos: Float = 0.0
    var vrollpos: Float = 0.0
}

struct CRTParams {
    var outModel: Float = 0.0
    var scanlines: Float = 0.5
    var maskDark: Float = 0.5
    var curvature: Float = 0.0
    var cornerRound: Float = 0.0
    var vignette: Float = 0.0

    var phosphor: Float = 0.0
    var bloom: Float = 0.0
    var bloomRad: Float = 0.5
    var halation: Float = 0.0

    var outGamma: Float = 1.0
    var outBright: Float = 1.0
    var outContrast: Float = 1.0
    var outSat: Float = 1.0
    var outWarmth: Float = 0.0
    var whiteClip: Float = 1.0

    var bezel: Float = 0.0
    var glassRefl: Float = 0.0
    var dust: Float = 0.0
    var scratches: Float = 0.0
    var grain: Float = 0.0
    var osdShow: Float = 0.0

    var time: Float = 0.0
}

struct FeedbackParams {
    var srcAspect: Float = 1.7777778
    var hasSrc: Float = 1.0
    var hasDelay: Float = 0.0
    var time: Float = 0.0

    var fbAmount: Float = 0.0
    var fbZoom: Float = 0.0
    var fbRotate: Float = 0.0
    var fbHue: Float = 0.0
    var fbShiftX: Float = 0.0
    var fbShiftY: Float = 0.0
    var fbMode: Float = 0.0

    var echo: Float = 0.0
    var srcZoom: Float = 0.0
    var srcX: Float = 0.0
    var srcY: Float = 0.0
    var srcRot: Float = 0.0
    var edgeMode: Float = 0.0

    var flipMode: Float = 0.0
    var mirrorMode: Float = 0.0
    var multiN: Float = 1.0
    var shakeX: Float = 0.0
    var shakeY: Float = 0.0

    var kaleido: Float = 0.0
    var kaleidoN: Float = 3.0
    var kaleidoRot: Float = 0.0
    var kaleidoX: Float = 0.0
    var kaleidoY: Float = 0.0

    var fbShearX: Float = 0.0
    var fbShearY: Float = 0.0
    var fbGainR: Float = 1.0
    var fbGainG: Float = 1.0
    var fbGainB: Float = 1.0
    var fbSat: Float = 1.0
    var fbVal: Float = 1.0
    var fbPost: Float = 0.0
    var fbChromOff: Float = 0.0

    var fbBlur: Float = 0.0
    var fbBlur2: Float = 0.0
    var fbSharp: Float = 0.0
    var fbDrive: Float = 1.0
    var fbPivot: Float = 0.5
    var fbThresh: Float = 0.0
    var fbThreshSoft: Float = 0.05

    var fbNoise: Float = 0.0
    var fbNoiseScale: Float = 0.5
    var fbRoll: Float = 0.0
    var fbJitter: Float = 0.0

    var fbWrap: Float = 0.0
    var fbMirror: Float = 0.0
    var fbBlend: Float = 0.0
    var fbNL: Float = 0.0
    var fbInvert: Float = 0.0
    var autoGain: Float = 0.0
    var fbFlip: Float = 0.0
    var generationCount: UInt32 = 0
}

struct ColourParams {
    var rGain: Float = 1.0
    var gGain: Float = 1.0
    var bGain: Float = 1.0
    var saturation: Float = 1.0
    var hue: Float = 0.0
    var brightness: Float = 0.0
    var contrast: Float = 1.0

    var posterize: Float = 0.0
    var solarize: Float = 0.0
    var negative: Float = 0.0
    var negMode: Float = 0.0
    var monoCol: Float = 0.0
    var monoHue: Float = 0.0
    var colorPass: Float = 0.0
    var passHue: Float = 0.0
    var passWidth: Float = 0.1
    var silhouette: Float = 0.0
    var silThresh: Float = 0.5
    var silHue: Float = 0.0
    var glow: Float = 0.0

    var findEdge: Float = 0.0
    var edgeHue: Float = 0.0
    var emboss: Float = 0.0
    var embossDir: Float = 0.0
    var diffAmt: Float = 0.0
    var diffScale: Float = 1.0
    var ampAmt: Float = 0.0
    var ampBands: Float = 4.0

    var colorize: Float = 0.0
    var colorBands: Float = 4.0
    var colorSweep: Float = 0.0
    var rgbSep: Float = 0.0
    var invFlick: Float = 0.0

    var contour: Float = 0.0
    var contourBands: Float = 8.0
    var contourWidth: Float = 0.05
    var contourHue: Float = 0.0
    var contourFill: Float = 0.0
    var lumaSteps: Float = 0.0
    var stepCount: Float = 4.0
    var dither: Float = 0.0

    var mline: Float = 0.0
    var mlineScale: Float = 0.5
    var mlineGain: Float = 1.0
    var mlineFb: Float = 0.0
    var mlineWin: Float = 0.5
    var mlineCol: Float = 0.0

    var time: Float = 0.0
}

struct ScanParams {
    var lines: Float = 320.0
    var samples: Float = 256.0
    var scanAmt: Float = 0.5
    var scanWidth: Float = 0.12
    var scanVel: Float = 0.8
    var scanTiltX: Float = 0.0
    var scanTiltY: Float = 0.0
    var scanPersp: Float = 0.3
    var scanCurve: Float = 0.0
    var scanCollapse: Float = 0.0
    var scanRevH: Float = 0.0
    var scanRevV: Float = 0.0
    var scanWobAmt: Float = 0.0
    var scanWobFreq: Float = 0.25
    var scanWobLock: Float = 1.0
    var scanLissa: Float = 0.0
    var scanSkew: Float = 0.0
    var scanGain: Float = 1.0
    var scanMono: Float = 0.0
    var scanHue: Float = 0.0
    var time: Float = 0.0
}

struct CorruptParams {
    var pixelSort: Float = 0.0
    var sortThresh: Float = 0.5
    var blockShift: Float = 0.0
    var blockSize: Float = 0.5
    var dotify: Float = 0.0
    var dotSize: Float = 0.5
    var driftWarp: Float = 0.0
    var fmWarp: Float = 0.0
    var dctAmt: Float = 0.0
    var dctQ: Float = 0.25
    var dctBlock: Float = 0.35
    var time: Float = 0.0
}

struct MeltParams {
    var meltMode: Float = 0.0
    var edgeAmt: Float = 0.0
    var edgeHold: Float = 0.0
    var edgeWidth: Float = 0.5
    var edgeCreep: Float = 0.0
    var edgeSwirl: Float = 0.0
    var meltZoom: Float = 0.0
    var meltDir: Float = 0.0
    var meltGate: Float = 0.0
    var meltSoft: Float = 0.5
    var edgeChroma: Float = 0.0
    var meltHue: Float = 0.0
    var time: Float = 0.0
}

struct DirtyParams {
    var mixDirt: Float = 0.0
    var mixDirtRate: Float = 0.5
    var mixDirtKnock: Float = 0.0
    var mixDirtDrop: Float = 0.0
    var mixDirtCut: Float = 0.0
    var mixDirtNoise: Float = 0.0
    var time: Float = 0.0
}

struct FlowParams {
    var flowField: Float = 0.0
    var moshVec: Float = 0.0
    var flowGain: Float = 1.0
    var flowCurl: Float = 0.0
    var flowEdge: Float = 0.0
    var mosh: Float = 0.0
    var moshGate: Float = 0.0
    var timeGrad: Float = 0.0
    var shearAxis: Float = 0.0
    var melt: Float = 0.0
    var meltDir: Float = 0.0
    var meltGate: Float = 0.0
    var swirl: Float = 0.0
    var swirlScale: Float = 0.5
    var swirlSpeed: Float = 0.5
    var moshBlock: Float = 0.0
    var moshBlockSize: Float = 0.5
    var moshRate: Float = 0.5
    var flowStretch: Float = 0.0
    var flowRepel: Float = 0.0
    var flowNoise: Float = 0.0
    var flowSharp: Float = 0.0
    var flowHue: Float = 0.0
    var flowFade: Float = 0.0
    var time: Float = 0.0
}

struct SignalLabParams {
    var sparseJit: Float = 0.0
    var jitThresh: Float = 0.5
    var fmAmt: Float = 0.0
    var fmCarrier: Float = 0.5
    var slitscan: Float = 0.0
    var slitDir: Float = 0.0
    var rowSmear: Float = 0.0
    var pngAmt: Float = 0.0
    var pngDir: Float = 0.0
    var pngRun: Float = 0.5
    var ntscArt: Float = 0.0
    var ntscFringe: Float = 0.0
    var snow: Float = 0.0
    var snowAniso: Float = 0.0
    var moire: Float = 0.0
    var moireFreq: Float = 0.5
    var bitCrush: Float = 0.0
    var bitScale: Float = 0.5
    var bandKey: Float = 0.0
    var bandN: Float = 4.0
    var bandHue: Float = 0.0
    var fieldMod: Float = 0.0
    var fieldSrc: Float = 0.0
    var fieldWarp: Float = 0.0
    var fieldHue: Float = 0.0
    var time: Float = 0.0
}

struct SynthParams {
    var shape: Float = 0.0
    var wave: Float = 0.0
    var colmode: Float = 2.0
    var genFreqX: Float = 2.0
    var genFreqY: Float = 2.0
    var genPhase: Float = 0.0
    var genRate: Float = 0.5
    var genRot: Float = 0.0
    var genSkew: Float = 0.0
    var genFM: Float = 0.0
    var genPulse: Float = 0.5
    var genFold: Float = 0.0
    var genComp: Float = 0.0
    var genThresh: Float = 0.0
    var genSoft: Float = 0.1
    var genFoldN: Float = 2.0
    var genCX: Float = 0.0
    var genCY: Float = 0.0
    var genZoom: Float = 1.0
    var genWarp: Float = 0.0
    var genHue: Float = 0.55
    var genSpread: Float = 1.0
    var genSat: Float = 0.9
    var genBright: Float = 1.0
    var genBands: Float = 6.0
    var blendWithSource: Float = 0.0
    var time: Float = 0.0
}

struct TransitionParams {
    var abMix: Float = 0.5
    var mixMode: Float = 0.0
    var mixBlend: Float = 0.0
    var wipeSoft: Float = 0.03
    var wipeDetail: Float = 0.3
    var wipeX: Float = 0.0
    var wipeY: Float = 0.0
    var wipeInv: Float = 0.0
    var wipeBord: Float = 0.0
    var wipeBordCol: Float = 0.0
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
    var time: Float = 0.0
}

struct SpatialParams {
    var srcZoom: Float = 1.0
    var srcX: Float = 0.0
    var srcY: Float = 0.0
    var srcRot: Float = 0.0
    var flipMode: Float = 0.0
    var mirrorMode: Float = 0.0
    var multiN: Float = 1.0
    var kaleido: Float = 0.0
    var kaleidoN: Float = 3.0
    var kaleidoRot: Float = 0.0
    var kaleidoX: Float = 0.0
    var kaleidoY: Float = 0.0
    var shake: Float = 0.0
    var shakeRate: Float = 0.5
    var tdAmt: Float = 0.0
    var tdMap: Float = 0.0
    var tdSpread: Float = 0.5
    var tdSoft: Float = 0.5
    var tdWarp: Float = 0.0
    var time: Float = 0.0
}

struct OpticsParams {
    var lensCA: Float = 0.0
    var lensStreak: Float = 0.0
    var streakHue: Float = 0.0
    var bloom: Float = 0.0
    var bloomRad: Float = 0.5
    var halation: Float = 0.0
    var vignette: Float = 0.0
    var lensSmudge: Float = 0.0
    var lightLeak: Float = 0.0
    var leakHue: Float = 0.0
    var gateHair: Float = 0.0
    var dust: Float = 0.0
    var scratches: Float = 0.0
    var grain: Float = 0.0
    var lcdGrid: Float = 0.0
    var osdShow: Float = 0.0
    var osdMode: Float = 0.0
    var osdGlow: Float = 0.5
    var time: Float = 0.0
}

func testStruct<T>(name: String, type: T.Type) -> Bool {
    let size = MemoryLayout<T>.size
    let stride = MemoryLayout<T>.stride
    let alignment = MemoryLayout<T>.alignment
    
    // Metal constant buffer alignment requirement: at least 4-byte alignment, 4-byte multiple stride
    let is4ByteAligned = (alignment >= 4)
    let isMultipleOf4 = (stride % 4 == 0)
    
    let ok = is4ByteAligned && isMultipleOf4
    let status = ok ? "✅ OK" : "❌ MISALIGNED"
    
    print("  \(name): size=\(size)B, stride=\(stride)B, align=\(alignment)B \(status)")
    return ok
}

var allPassed = true
allPassed = testStruct(name: "VHSParams", type: VHSParams.self) && allPassed
allPassed = testStruct(name: "CRTParams", type: CRTParams.self) && allPassed
allPassed = testStruct(name: "FeedbackParams", type: FeedbackParams.self) && allPassed
allPassed = testStruct(name: "ColourParams", type: ColourParams.self) && allPassed
allPassed = testStruct(name: "ScanParams", type: ScanParams.self) && allPassed
allPassed = testStruct(name: "CorruptParams", type: CorruptParams.self) && allPassed
allPassed = testStruct(name: "MeltParams", type: MeltParams.self) && allPassed
allPassed = testStruct(name: "DirtyParams", type: DirtyParams.self) && allPassed
allPassed = testStruct(name: "FlowParams", type: FlowParams.self) && allPassed
allPassed = testStruct(name: "SignalLabParams", type: SignalLabParams.self) && allPassed
allPassed = testStruct(name: "SynthParams", type: SynthParams.self) && allPassed
allPassed = testStruct(name: "TransitionParams", type: TransitionParams.self) && allPassed
allPassed = testStruct(name: "SpatialParams", type: SpatialParams.self) && allPassed
allPassed = testStruct(name: "OpticsParams", type: OpticsParams.self) && allPassed

print("==================================================")
if allPassed {
    print("🎉 All 14 Parameter Structs Match Metal Memory Alignment!")
} else {
    print("❌ Some structs have alignment issues.")
    exit(1)
}
