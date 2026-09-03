// BENDROpticsParams.swift — Parameter declarations and state model for BENDR Optics

import Foundation
import FxPlug

struct OpticsParams: BendrParams {
    // Optical & Lens
    var lensCA: Float = 0.0        // Chromatic aberration (0..1)
    var lensStreak: Float = 0.0    // Anamorphic horizontal flare streak (0..1)
    var streakHue: Float = 0.5     // Anamorphic streak blue coating tint (0..1)
    var bloom: Float = 0.0         // Optical highlight bloom (0..1)
    var bloomRad: Float = 0.3      // Bloom radius (0..1)
    var halation: Float = 0.0      // Film halation / red fringe (0..1)
    var vignette: Float = 0.3      // Optical lens vignette (0..1)

    // Glass & Film Texture
    var lensSmudge: Float = 0.0    // Highlight-gated dirty glass smudge (0..1)
    var lightLeak: Float = 0.0     // Film light leak / fogging (0..1)
    var leakHue: Float = 0.08      // Light leak color hue (0..1)
    var gateHair: Float = 0.0      // Projector gate hair (0..1)
    var dust: Float = 0.0          // Dust & lint specks (0..1)
    var scratches: Float = 0.0     // Film stock vertical scratches (0..1)
    var grain: Float = 0.0         // Film grain (0..1)

    // Display & Camcorder OSD
    var lcdGrid: Float = 0.0       // Flat panel LCD subpixel grid (0..1)
    var osdShow: Float = 0.0       // Camcorder on-screen display (0..1)
    var osdMode: Float = 0.0       // 0: REC + Battery + TC, 1: Playback HUD, 2: Minimal TC
    var osdGlow: Float = 0.5       // OSD phosphor glow (0..1)

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum OpticsParamID: UInt32 {
    case groupLens         = 9601
    case lensCA            = 9602
    case lensStreak        = 9603
    case streakHue         = 9604
    case bloom             = 9605
    case bloomRad          = 9606
    case halation          = 9607
    case vignette          = 9608

    case groupTexture      = 9610
    case lensSmudge        = 9611
    case lightLeak         = 9612
    case leakHue           = 9613
    case gateHair          = 9614
    case dust              = 9615
    case scratches         = 9616
    case grain             = 9617

    case groupDisplay      = 9620
    case lcdGrid           = 9621
    case osdShow           = 9622
    case osdMode           = 9623
    case osdGlow           = 9624
}
