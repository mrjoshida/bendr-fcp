// BENDRSpatialParams.swift — Parameter declarations and state model for BENDR Spatial

import Foundation
import FxPlug

struct SpatialParams: BendrParams {
    // Framing & Geometry
    var srcZoom: Float = 0.0       // Zoom (-1..1)
    var srcX: Float = 0.0          // Pan X (-1..1)
    var srcY: Float = 0.0          // Pan Y (-1..1)
    var srcRot: Float = 0.0        // Rotate (-1..1)
    var flipMode: Float = 0.0      // 0: None, 1: Flip H, 2: Flip V, 3: Flip HV
    var mirrorMode: Float = 0.0    // 0: None, 1: Mirror H, 2: Mirror V, 3: Mirror 4-Way
    var multiN: Float = 1.0        // Grid tiling count (1..8)

    // Kaleidoscope Symmetries
    var kaleido: Float = 0.0       // Kaleidoscope enable/blend (0..1)
    var kaleidoN: Float = 3.0      // Fold sector count (2..12)
    var kaleidoRot: Float = 0.0    // Fold spin rotation (-1..1)
    var kaleidoX: Float = 0.0      // Fold origin X (-1..1)
    var kaleidoY: Float = 0.0      // Fold origin Y (-1..1)

    // Camera Shake & Motion
    var shake: Float = 0.0         // Camera shake intensity (0..1)
    var shakeRate: Float = 0.5     // Shake rate / frequency (0..1)

    // Time Displacement Mapping
    var tdAmt: Float = 0.0         // Time displacement amount (0..1)
    var tdMap: Float = 0.0         // Map type: 0=Slitscan V, 1=Sweep H, 2=Luma Map, 3=Radial, 4=Failing TBC Lines
    var tdSpread: Float = 0.7      // Reach / frame depth (0..1)
    var tdSoft: Float = 1.0        // Interpolation softness (0..1)
    var tdWarp: Float = 0.0        // Map drift animation (0..1)

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum SpatialParamID: UInt32 {
    case groupFraming      = 9401
    case srcZoom           = 9402
    case srcX              = 9403
    case srcY              = 9404
    case srcRot            = 9405
    case flipMode          = 9406
    case mirrorMode        = 9407
    case multiN            = 9408

    case groupKaleido      = 9410
    case kaleido           = 9411
    case kaleidoN          = 9412
    case kaleidoRot        = 9413
    case kaleidoX          = 9414
    case kaleidoY          = 9415

    case groupShake        = 9420
    case shake             = 9421
    case shakeRate         = 9422

    case groupTimeDisp     = 9430
    case tdAmt             = 9431
    case tdMap             = 9432
    case tdSpread          = 9433
    case tdSoft            = 9434
    case tdWarp            = 9435
}
