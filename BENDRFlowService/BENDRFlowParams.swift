// BENDRFlowParams.swift — Parameter declarations and state model for BENDR Flow

import Foundation
import FxPlug

struct FlowParams: BendrParams {
    var flowField: Float = 0.0     // 0: Motion, 1: Contour, 2: Curl Noise, 3: Radial, 4: Spiral, 5: Chroma, 6: Weave
    var moshVec: Float = 0.5       // P-Frame Push / Field Force (0..1)
    var flowGain: Float = 1.0      // Field Velocity Gain (0..3)
    var flowCurl: Float = 0.0      // Field Curl / Orbit Rotation (-1..1)
    var flowEdge: Float = 0.0      // Edge Mode: 0=Clamp, 1=Wrap/Repeat, 2=Mirror

    var mosh: Float = 0.7          // Mosh Hold / Persistence (0..0.99)
    var moshGate: Float = 0.0      // Mosh Gate (-1..1)
    var timeGrad: Float = 0.0      // Time Shear Gradient (-1..1)
    var shearAxis: Float = 0.0     // Shear Axis: 0=Vertical, 1=Horizontal

    var melt: Float = 0.0          // Gravity Melt (0..1)
    var meltDir: Float = 0.0       // Melt Angle (-1..1)
    var meltGate: Float = 0.0      // Melt Luma Gate (0..1)
    var swirl: Float = 0.0         // Turbulence Swirl (0..1)
    var swirlScale: Float = 0.18   // Swirl Scale (0..1)
    var swirlSpeed: Float = 0.08   // Swirl Speed (0..1)

    var moshBlock: Float = 0.0     // Vector Trash (0..1)
    var moshBlockSize: Float = 0.68 // Trash Block Size (0..1)
    var moshRate: Float = 0.13     // Trash Rate (0..1)
    var flowStretch: Float = 0.0   // Center Stretch (-1..1)
    var flowRepel: Float = 0.0     // Edge Contrast Repel (-1..1)
    var flowNoise: Float = 0.0     // Flow Noise (0..1)
    var flowSharp: Float = 0.0     // Re-Sharpening (0..1)
    var flowHue: Float = 0.0       // Hue Shift / Pass (-1..1)
    var flowFade: Float = 0.0      // Decay / Pass (0..1)

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum FlowParamID: UInt32 {
    case groupField         = 7001
    case flowField          = 7002
    case moshVec            = 7003
    case flowGain           = 7004
    case flowCurl           = 7005
    case flowEdge           = 7006

    case groupPersistence   = 7010
    case mosh               = 7011
    case moshGate           = 7012
    case timeGrad           = 7013
    case shearAxis          = 7014

    case groupDynamics      = 7020
    case melt               = 7021
    case meltDir            = 7022
    case meltGate           = 7023
    case swirl              = 7024
    case swirlScale         = 7025
    case swirlSpeed         = 7026

    case groupGlitch        = 7030
    case moshBlock          = 7031
    case moshBlockSize      = 7032
    case moshRate           = 7033
    case flowStretch        = 7034
    case flowRepel          = 7035
    case flowNoise          = 7036
    case flowSharp          = 7037
    case flowHue            = 7038
    case flowFade           = 7039
}
