// BENDRFeedbackParams.swift — Parameter declarations and state model for BENDR Feedback

import Foundation
import FxPlug

struct FeedbackParams: BendrParams {
    var srcAspect: Float = 1.7777778
    var hasSrc: Float = 1.0
    var hasDelay: Float = 0.0
    var time: Float = 0.0

    var fbAmount: Float = 0.0
    var fbZoom: Float = 0.0
    var fbRotate: Float = 0.0
    var fbHue: Float = 0.0
    var fbShiftX: Float = 0.0
    var fbShiftY: Float = 0.0
    var fbMode: Float = 0.0

    var echo: Float = 0.0
    var srcZoom: Float = 0.0
    var srcX: Float = 0.0
    var srcY: Float = 0.0
    var srcRot: Float = 0.0
    var edgeMode: Float = 0.0

    var flipMode: Float = 0.0
    var mirrorMode: Float = 0.0
    var multiN: Float = 1.0
    var shakeX: Float = 0.0
    var shakeY: Float = 0.0

    var kaleido: Float = 0.0
    var kaleidoN: Float = 3.0
    var kaleidoRot: Float = 0.0
    var kaleidoX: Float = 0.0
    var kaleidoY: Float = 0.0

    var fbShearX: Float = 0.0
    var fbShearY: Float = 0.0
    var fbGainR: Float = 1.0
    var fbGainG: Float = 1.0
    var fbGainB: Float = 1.0
    var fbSat: Float = 1.0
    var fbVal: Float = 1.0
    var fbPost: Float = 0.0
    var fbChromOff: Float = 0.0

    var fbBlur: Float = 0.0
    var fbBlur2: Float = 0.0
    var fbSharp: Float = 0.0
    var fbDrive: Float = 1.0
    var fbPivot: Float = 0.5
    var fbThresh: Float = 0.0
    var fbThreshSoft: Float = 0.05

    var fbNoise: Float = 0.0
    var fbNoiseScale: Float = 0.5
    var fbRoll: Float = 0.0
    var fbJitter: Float = 0.0

    var fbWrap: Float = 0.0
    var fbMirror: Float = 0.0
    var fbBlend: Float = 0.0
    var fbNL: Float = 0.0
    var fbInvert: Float = 0.0
    var autoGain: Float = 0.0
    var fbFlip: Float = 0.0
    var generationCount: UInt32 = 0
}

enum FeedbackParamID: UInt32 {
    // Feedback Core
    case groupCore      = 3901
    case fbAmount       = 3000
    case fbZoom         = 3001
    case fbRotate       = 3002
    case fbHue          = 3003
    case fbShiftX       = 3004
    case fbShiftY       = 3005
    case fbMode         = 3006

    // Feedback Shape
    case fbShearX       = 3010
    case fbShearY       = 3011
    case fbWrap         = 3012
    case fbMirror       = 3013
    case fbFlip         = 3014
    case fbBlend        = 3015

    // Feedback Color
    case groupColor     = 3902
    case fbGainR        = 3020
    case fbGainG        = 3021
    case fbGainB        = 3022
    case fbSat          = 3023
    case fbVal          = 3024
    case fbPost         = 3025
    case fbChromOff     = 3026
    case fbInvert       = 3027
    case fbAuto         = 3028

    // Feedback Dynamics
    case groupDynamics  = 3903
    case fbBlur         = 3030
    case fbBlur2        = 3031
    case fbSharp        = 3032
    case fbDrive        = 3033
    case fbPivot        = 3034
    case fbThresh       = 3035
    case fbThreshSoft   = 3036
    case fbNL           = 3037

    // Feedback Noise
    case groupNoise     = 3904
    case fbNoise        = 3040
    case fbNoiseScale   = 3041
    case fbRoll         = 3042
    case fbJitter       = 3043

    // Time Base
    case groupTime      = 3905
    case echo           = 3050
    case delayFrames    = 3051
    case stutter        = 3052
    case strobe         = 3053
    case shake          = 3054
    case shakeRate      = 3055

    // Source Framing
    case groupSource    = 3900
    case srcZoom        = 3060
    case srcX           = 3061
    case srcY           = 3062
    case srcRot         = 3063
    case flipMode       = 3064
    case mirrorMode     = 3065
    case multiN         = 3066
    case kaleido        = 3067
    case kaleidoN       = 3068
    case kaleidoRot     = 3069
    case kaleidoX       = 3070
    case kaleidoY       = 3071
    case edgeMode       = 3072
}
