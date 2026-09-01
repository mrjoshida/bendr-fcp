// BENDRMeltParams.swift — Parameter declarations and state model for BENDR Melt

import Foundation
import FxPlug

struct MeltParams: BendrParams {
    var meltMode: Float = 0.0       // 0: Edge Smear, 1: Spiral Feedback, 2: Motion Driven, 3: Gravity Melt
    var edgeAmt: Float = 0.5        // Melt amount / drift distance (0..2)
    var edgeHold: Float = 0.6       // Melt hold / persistence ceiling (0..1.5)
    var edgeWidth: Float = 0.3      // Melt width / motion threshold (0..2)
    var edgeCreep: Float = 0.35     // Edge creep / outgoing bias (0..1)
    var edgeSwirl: Float = 0.0      // Swirl / spiral rotation (-1..1)
    var meltZoom: Float = 0.0       // Zoom per pass (-1..1)
    var meltDir: Float = 0.0        // Melt angle / gravity direction (-1..1)
    var meltGate: Float = 0.0       // Luma gate threshold (0..1)
    var meltSoft: Float = 0.35      // Soften / blur radius per pass (0..1)
    var edgeChroma: Float = 0.5     // Chroma spread / color bleed (0..1)
    var meltHue: Float = 0.0        // Hue shift / rainbow per pass (-1..1)
    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum MeltParamID: UInt32 {
    case groupDynamics  = 9001
    case meltMode       = 9002
    case edgeAmt        = 9003
    case edgeHold       = 9004
    case edgeWidth      = 9005
    case edgeCreep      = 9006

    case groupSpatial   = 9010
    case edgeSwirl      = 9011
    case meltZoom       = 9012
    case meltDir        = 9013
    case meltGate       = 9014

    case groupColor     = 9020
    case meltSoft       = 9021
    case edgeChroma     = 9022
    case meltHue        = 9023
}
