// BENDRColourParams.swift — Parameter declarations and state model for BENDR Colour

import Foundation
import FxPlug

struct ColourParams: BendrParams {
    // Primary Color
    var rGain: Float = 1.0
    var gGain: Float = 1.0
    var bGain: Float = 1.0
    var saturation: Float = 1.0
    var hue: Float = 0.0
    var brightness: Float = 0.0
    var contrast: Float = 1.0

    // Color Effects
    var posterize: Float = 0.0
    var solarize: Float = 0.0
    var negative: Float = 0.0
    var negMode: Float = 0.0
    var monoCol: Float = 0.0
    var monoHue: Float = 0.55
    var colorPass: Float = 0.0
    var passHue: Float = 0.0
    var passWidth: Float = 0.25
    var silhouette: Float = 0.0
    var silThresh: Float = 0.45
    var silHue: Float = 0.08
    var glow: Float = 0.15

    // Edge & Relief
    var findEdge: Float = 0.0
    var edgeHue: Float = 0.45
    var emboss: Float = 0.0
    var embossDir: Float = 0.12
    var diffAmt: Float = 0.0
    var diffScale: Float = 0.2
    var diffPolar: Float = 0.0
    var ampAmt: Float = 0.0
    var ampBands: Float = 0.5
    var ampPick: Float = 0.0
    var ampCol: Float = 0.0

    // Function Generator
    var fgPos: Float = 0.0
    var fgNeg: Float = 0.0
    var fgZero: Float = 0.0

    // Bent Enhancer
    var colorize: Float = 0.0
    var colorBands: Float = 1.5
    var colorSweep: Float = 0.15
    var lumaHue: Float = 0.0
    var sharpEcho: Float = 0.0
    var echoSpace: Float = 0.3
    var rgbSep: Float = 0.0
    var invFlick: Float = 0.0

    // Contour & Dither
    var contour: Float = 0.0
    var contourBands: Float = 10.0
    var contourWidth: Float = 1.2
    var contourHue: Float = 0.0
    var contourFill: Float = 0.25
    var lumaSteps: Float = 0.0
    var stepCount: Float = 5.0
    var dither: Float = 0.0

    // Modulation Lines
    var mline: Float = 0.0
    var mlineScale: Float = 1.0
    var mlineGain: Float = 1.15
    var mlineBias: Float = 0.0
    var mlineFb: Float = 0.92
    var mlineWin: Float = 32.0
    var mlineTint: Float = 0.0
    var mlineCol: Float = 0.0
    var mlineSerp: Float = 1.0

    // System
    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum ColourParamID: UInt32 {
    case groupPrimary       = 4001
    case rGain              = 4002
    case gGain              = 4003
    case bGain              = 4004
    case saturation         = 4005
    case hue                = 4006
    case brightness         = 4007
    case contrast           = 4008

    case groupEffects       = 4010
    case posterize          = 4011
    case solarize           = 4012
    case negative           = 4013
    case negMode            = 4014
    case monoCol            = 4015
    case monoHue            = 4016
    case colorPass          = 4017
    case passHue            = 4018
    case passWidth          = 4019
    case silhouette         = 4020
    case silThresh          = 4021
    case silHue             = 4022
    case glow               = 4023

    case groupEdge          = 4030
    case findEdge           = 4031
    case edgeHue            = 4032
    case emboss             = 4033
    case embossDir          = 4034
    case diffAmt            = 4035
    case diffScale          = 4036
    case diffPolar          = 4037
    case ampAmt             = 4038
    case ampBands           = 4039

    case groupEnhancer      = 4040
    case colorize           = 4041
    case colorBands         = 4042
    case colorSweep         = 4043
    case rgbSep             = 4044
    case invFlick           = 4045

    case groupContour       = 4050
    case contour            = 4051
    case contourBands       = 4052
    case contourWidth       = 4053
    case contourHue         = 4054
    case contourFill        = 4055
    case lumaSteps          = 4056
    case stepCount          = 4057
    case dither             = 4058

    case groupModulation    = 4060
    case mline              = 4061
    case mlineScale         = 4062
    case mlineGain          = 4063
    case mlineBias          = 4064
    case mlineFb            = 4065
    case mlineWin           = 4066
    case mlineTint          = 4067
    case mlineCol           = 4068
    case mlineSerp          = 4069
}
