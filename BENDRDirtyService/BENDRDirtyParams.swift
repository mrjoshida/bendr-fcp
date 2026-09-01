// BENDRDirtyParams.swift — Parameter declarations and state model for BENDR Dirty

import Foundation
import FxPlug

struct DirtyParams: BendrParams {
    var mixDirt: Float = 0.5       // Dirt amount / event trigger probability (0..1)
    var mixDirtRate: Float = 0.3   // Event clock rate (0..1)
    var mixDirtKnock: Float = 0.5  // Timebase knock / horizontal shear (0..1)
    var mixDirtDrop: Float = 0.5   // Line dropout severity (0..1)
    var mixDirtCut: Float = 0.4    // Switching flash / transient cut (0..1)
    var mixDirtNoise: Float = 0.35 // Switching transient noise (0..1)
    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum DirtyParamID: UInt32 {
    case groupEngine        = 9501
    case mixDirt            = 9502
    case mixDirtRate        = 9503

    case groupManifestation = 9510
    case mixDirtKnock       = 9511
    case mixDirtDrop        = 9512
    case mixDirtCut         = 9513
    case mixDirtNoise       = 9514
}
