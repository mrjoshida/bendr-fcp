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
    case groupLens         = 13001
    case lensCA            = 13002
    case lensStreak        = 13003
    case streakHue         = 13004
    case bloom             = 13005
    case bloomRad          = 13006
    case halation          = 13007
    case vignette          = 13008

    case groupTexture      = 13010
    case lensSmudge        = 13011
    case lightLeak         = 13012
    case leakHue           = 13013
    case gateHair          = 13014
    case dust              = 13015
    case scratches         = 13016
    case grain             = 13017

    case groupDisplay      = 13020
    case lcdGrid           = 13021
    case osdShow           = 13022
    case osdMode           = 13023
    case osdGlow           = 13024
}
