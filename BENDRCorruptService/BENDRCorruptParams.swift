// BENDRCorruptParams.swift — Parameter declarations and state model for BENDR Corrupt

import Foundation
import FxPlug

struct CorruptParams: BendrParams {
    var pixelSort: Float = 0.0
    var sortThresh: Float = 0.45
    var blockShift: Float = 0.0
    var blockSize: Float = 0.35
    var dotify: Float = 0.0
    var dotSize: Float = 0.4
    var driftWarp: Float = 0.0
    var fmWarp: Float = 0.0
    var dctAmt: Float = 0.0
    var dctQ: Float = 0.25
    var dctTilt: Float = 0.5
    var dctChroma: Float = 0.4
    var dctBlock: Float = 0.35
    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum CorruptParamID: UInt32 {
    case groupGlitch       = 6001
    case pixelSort         = 6002
    case sortThresh        = 6003
    case blockShift        = 6004
    case blockSize         = 6005
    case dotify            = 6006
    case dotSize           = 6007

    case groupWarp         = 6010
    case driftWarp         = 6011
    case fmWarp            = 6012

    case groupDCT          = 6020
    case dctAmt            = 6021
    case dctQ              = 6022
    case dctTilt           = 6023
    case dctChroma         = 6024
    case dctBlock          = 6025
}
