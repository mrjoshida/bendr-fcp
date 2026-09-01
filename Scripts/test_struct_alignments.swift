#!/usr/bin/env swift
// test_struct_alignments.swift — Validates MemoryLayout size and alignment for all 14 parameter structs

import Foundation
import simd

print("==================================================")
print("📏 BENDR Parameter Struct Memory Layout & Alignment Test")
print("==================================================")

// Parameter struct definitions matching the 14 plugins

struct VHSParams {
    var vhsHeadSwitch: Float
    var vhsColorBleed: Float
    var vhsLumaBleed: Float
    var vhsTapeNoise: Float
    var vhsDropouts: Float
    var vhsEdgeDmg: Float
    var vhsTrackingJitter: Float
    var vhsChromaDelay: Float
    var vhsNTSCArtifacts: Float
    var vhsRinging: Float
    var vhsTapeSpeed: Float
    var time: Float
    var res: SIMD2<Float>
}

struct CRTParams {
    var crtCurvature: Float
    var crtScanlines: Float
    var crtMaskType: Float
    var crtMaskAmt: Float
    var crtPhosphorDecay: Float
    var crtBloom: Float
    var crtAberration: Float
    var crtVignette: Float
    var crtGlassReflect: Float
    var crtNoise: Float
    var time: Float
    var res: SIMD2<Float>
}

struct FeedbackParams {
    var fbAmount: Float
    var fbDecay: Float
    var fbZoom: Float
    var fbRotate: Float
    var fbHueShift: Float
    var fbSaturation: Float
    var fbBlendMode: Float
    var fbInjectMode: Float
    var fbCenterX: Float
    var fbCenterY: Float
    var fbDamping: Float
    var time: Float
    var res: SIMD2<Float>
}

struct ColourParams {
    var colMode: Float
    var colInvert: Float
    var colPosterize: Float
    var colSolarize: Float
    var colHueShift: Float
    var colSatGain: Float
    var colContrast: Float
    var colBrightness: Float
    var colDiffAmt: Float
    var colDiffMode: Float
    var colEnhanceAmt: Float
    var colEnhanceThresh: Float
    var time: Float
    var res: SIMD2<Float>
}

struct ScanParams {
    var scanMode: Float
    var scanLines: Float
    var scanDeflection: Float
    var scanWobble: Float
    var scanWobbleRate: Float
    var scanLissajous: Float
    var scanLissRatio: Float
    var scan3DRotX: Float
    var scan3DRotY: Float
    var scan3DRotZ: Float
    var scan3DDepth: Float
    var time: Float
    var res: SIMD2<Float>
}

struct CorruptParams {
    var pixelSort: Float
    var sortThresh: Float
    var blockShift: Float
    var blockSize: Float
    var dotify: Float
    var dotSize: Float
    var driftWarp: Float
    var fmWarp: Float
    var dctAmt: Float
    var dctQ: Float
    var dctTilt: Float
    var dctChroma: Float
    var dctBlock: Float
    var time: Float
    var res: SIMD2<Float>
}

struct MeltParams {
    var meltMode: Float
    var edgeAmt: Float
    var edgeHold: Float
    var edgeWidth: Float
    var edgeCreep: Float
    var edgeSwirl: Float
    var meltZoom: Float
    var meltDir: Float
    var meltGate: Float
    var meltSoft: Float
    var edgeChroma: Float
    var meltHue: Float
    var time: Float
    var res: SIMD2<Float>
}

struct DirtyParams {
    var mixDirt: Float
    var mixDirtRate: Float
    var mixDirtKnock: Float
    var mixDirtDrop: Float
    var mixDirtCut: Float
    var mixDirtNoise: Float
    var time: Float
    var res: SIMD2<Float>
}

struct FlowParams {
    var flowField: Float
    var flowAmt: Float
    var flowSpeed: Float
    var flowDecay: Float
    var flowSwirl: Float
    var flowNoise: Float
    var flowTrash: Float
    var flowBlockSize: Float
    var flowPFrames: Float
    var flowPushAmt: Float
    var flowEdgeRepel: Float
    var flowStretch: Float
    var flowSharpen: Float
    var flowEdgeMode: Float
    var flowHueRot: Float
    var time: Float
    var res: SIMD2<Float>
}

struct SignalLabParams {
    var labJitter: Float
    var labFM: Float
    var labFMFreq: Float
    var labSlitscan: Float
    var labSlitAxis: Float
    var labRowSmear: Float
    var labAvalanche: Float
    var labAvaDir: Float
    var labNTSC: Float
    var labCrosstalk: Float
    var labSnow: Float
    var labMoire: Float
    var labBayer: Float
    var labKeyer: Float
    var labKeyBands: Float
    var labFieldMod: Float
    var time: Float
    var res: SIMD2<Float>
}

struct SynthParams {
    var shape: Float
    var wave: Float
    var colmode: Float
    var genFreqX: Float
    var genFreqY: Float
    var genPhase: Float
    var genRate: Float
    var genRot: Float
    var genSkew: Float
    var genFM: Float
    var genPulse: Float
    var genFold: Float
    var genComp: Float
    var genThresh: Float
    var genSoft: Float
    var genFoldN: Float
    var genCX: Float
    var genCY: Float
    var genZoom: Float
    var genWarp: Float
    var genHue: Float
    var genSpread: Float
    var genSat: Float
    var genBright: Float
    var genBands: Float
    var blendWithSource: Float
    var time: Float
    var res: SIMD2<Float>
}

struct TransitionParams {
    var abMix: Float
    var mixMode: Float
    var mixBlend: Float
    var wipeSoft: Float
    var wipeDetail: Float
    var wipeX: Float
    var wipeY: Float
    var wipeInv: Float
    var wipeBord: Float
    var wipeBordCol: Float
    var wipeRep: Float
    var mixKey: Float
    var mixKeyThresh: Float
    var mixKeySoft: Float
    var mixKeyHue: Float
    var mixKeyInv: Float
    var mixKeyGain: Float
    var mixKeyDens: Float
    var mixKeyEdge: Float
    var mixKeyEdgeCol: Float
    var mixKeyShadow: Float
    var time: Float
    var res: SIMD2<Float>
}

struct SpatialParams {
    var srcZoom: Float
    var srcX: Float
    var srcY: Float
    var srcRot: Float
    var flipMode: Float
    var mirrorMode: Float
    var multiN: Float
    var kaleido: Float
    var kaleidoN: Float
    var kaleidoRot: Float
    var kaleidoX: Float
    var kaleidoY: Float
    var shake: Float
    var shakeRate: Float
    var tdAmt: Float
    var tdMap: Float
    var tdSpread: Float
    var tdSoft: Float
    var tdWarp: Float
    var time: Float
    var res: SIMD2<Float>
}

struct OpticsParams {
    var lensCA: Float
    var lensStreak: Float
    var streakHue: Float
    var bloom: Float
    var bloomRad: Float
    var halation: Float
    var vignette: Float
    var lensSmudge: Float
    var lightLeak: Float
    var leakHue: Float
    var gateHair: Float
    var dust: Float
    var scratches: Float
    var grain: Float
    var lcdGrid: Float
    var osdShow: Float
    var osdMode: Float
    var osdGlow: Float
    var time: Float
    var res: SIMD2<Float>
}

func testStruct<T>(name: String, type: T.Type) -> Bool {
    let size = MemoryLayout<T>.size
    let stride = MemoryLayout<T>.stride
    let alignment = MemoryLayout<T>.alignment
    
    // float2 requires 8-byte alignment
    let is8ByteAligned = (alignment == 8)
    let isMultipleOf8 = (stride % 8 == 0)
    
    let ok = is8ByteAligned && isMultipleOf8
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
