// BENDRTransitionParams.swift — Parameter declarations and state model for BENDR Transition

import Foundation
import FxPlug

struct TransitionParams: BendrParams {
    var abMix: Float = 0.5         // Transition progress fader (0..1)
    var mixMode: Float = 0.0       // Wipe / transition type
    var mixBlend: Float = 0.0      // Hardware blend mode (0..23)
    var wipeSoft: Float = 0.03     // Wipe softness (0..1)
    var wipeDetail: Float = 0.3    // Wipe pattern frequency / detail (0..1)
    var wipeX: Float = 0.0         // Wipe origin X (-1..1)
    var wipeY: Float = 0.0         // Wipe origin Y (-1..1)
    var wipeInv: Float = 0.0       // Wipe invert (0 or 1)
    var wipeBord: Float = 0.0      // Border wipe line (0..1)
    var wipeBordCol: Float = 0.0   // Border color index (0..1)
    var wipeRep: Float = 1.0       // Multi-tiling multiplier (1..4)

    var mixKey: Float = 0.0        // Key mode: 0=Off, 1=White, 2=Black, 3=Chroma, 4=PIP
    var mixKeyThresh: Float = 0.5  // Key threshold (0..1)
    var mixKeySoft: Float = 0.2    // Key softness (0.01..1)
    var mixKeyHue: Float = 0.33    // Key chroma target hue (0..1)
    var mixKeyInv: Float = 0.0     // Key invert (0 or 1)
    var mixKeyGain: Float = 0.5    // Key amplifier gain (0..1)
    var mixKeyDens: Float = 1.0    // Key density (0..1)
    var mixKeyEdge: Float = 0.0    // Key border (0..1)
    var mixKeyEdgeCol: Float = 0.0 // Key border color (0..1)
    var mixKeyShadow: Float = 0.0  // Key shadow (0..1)

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum TransitionParamID: UInt32 {
    case groupTransition   = 11001
    case abMix             = 11002
    case mixMode           = 11003
    case mixBlend          = 11004

    case groupWipe         = 11010
    case wipeSoft          = 11011
    case wipeDetail        = 11012
    case wipeX             = 11013
    case wipeY             = 11014
    case wipeInv           = 11015
    case wipeBord          = 11016
    case wipeBordCol       = 11017
    case wipeRep           = 11018

    case groupKey          = 11020
    case mixKey            = 11021
    case mixKeyThresh      = 11022
    case mixKeySoft        = 11023
    case mixKeyHue         = 11024
    case mixKeyInv         = 11025
    case mixKeyGain        = 11026
    case mixKeyDens        = 11027
    case mixKeyEdge        = 11028
    case mixKeyEdgeCol     = 11029
    case mixKeyShadow      = 11030
}
