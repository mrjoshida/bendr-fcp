// BENDRSignalLabParams.swift — Parameter declarations and state model for BENDR Signal Lab

import Foundation
import FxPlug

struct SignalLabParams: BendrParams {
    // Raster Glitch & Displacement
    var sparseJit: Float = 0.0     // Sparse line jitter (0..1)
    var jitThresh: Float = 0.7     // Jitter gate threshold (0..1)
    var fmAmt: Float = 0.0         // FM carrier wobble (0..1)
    var fmCarrier: Float = 0.35    // FM carrier frequency (0..1)
    var slitscan: Float = 0.0      // Slitscan displacement (0..1)
    var slitDir: Float = 0.0       // Slitscan axis: 0=H, 1=V
    var rowSmear: Float = 0.0      // Misaligned row reconstruction (0..1)

    // Codec & Signal Breakdown
    var pngAmt: Float = 0.0        // PNG filter reconstruction avalanche (0..1)
    var pngDir: Float = 0.0        // Avalanche axis: 0=Sub/H, 1=Up/V, 2=Avg/Diag
    var pngRun: Float = 0.4        // Avalanche run span (0..1)
    var ntscArt: Float = 0.0       // NTSC composite artifact color (0..1)
    var ntscFringe: Float = 0.0    // NTSC chroma fringing crosstalk (0..1)
    var snow: Float = 0.0          // CRT snow (0..1)
    var snowAniso: Float = 0.4     // Snow clumping / anisotropy (0..1)
    var moire: Float = 0.0         // Moire interference pattern (0..1)
    var moireFreq: Float = 0.4     // Moire frequency (0..1)

    // Quantization & Field Mod
    var bitCrush: Float = 0.0      // 1-Bit Bayer dither crush (0..1)
    var bitScale: Float = 0.4      // Crush pixel block scale (0..1)
    var bandKey: Float = 0.0       // Multi-band sequential keyer (0..1)
    var bandN: Float = 5.0         // Band count (2..12)
    var bandHue: Float = 0.3       // Band hue offset (0..1)
    var fieldMod: Float = 0.0      // Video-rate field modulation (0..1)
    var fieldSrc: Float = 0.0      // Field source: 0=H-Ramp, 1=V-Ramp, 2=Radial, 3=Sine, 4=Noise
    var fieldWarp: Float = 0.0     // Field -> Warp (-1..1)
    var fieldHue: Float = 0.0      // Field -> Hue (-1..1)

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum SignalLabParamID: UInt32 {
    case groupRaster        = 8001
    case sparseJit          = 8002
    case jitThresh          = 8003
    case fmAmt              = 8004
    case fmCarrier          = 8005
    case slitscan           = 8006
    case slitDir            = 8007
    case rowSmear           = 8008

    case groupSignal        = 8010
    case pngAmt             = 8011
    case pngDir             = 8012
    case pngRun             = 8013
    case ntscArt            = 8014
    case ntscFringe         = 8015
    case snow               = 8016
    case snowAniso          = 8017
    case moire              = 8018
    case moireFreq          = 8019

    case groupQuant         = 8020
    case bitCrush           = 8021
    case bitScale           = 8022
    case bandKey            = 8023
    case bandN              = 8024
    case bandHue            = 8025
    case fieldMod           = 8026
    case fieldSrc           = 8027
    case fieldWarp          = 8028
    case fieldHue           = 8029
}
