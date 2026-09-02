// BENDRCRTParams.swift — Parameter declarations and state model for BENDR CRT

import Foundation
import FxPlug

struct CRTParams: BendrParams {
    var procRes: SIMD2<Float> = SIMD2<Float>(1920, 1080)
    var scanlines: Float = 0.5
    var beamWidth: Float = 1.0
    var beamShape: Float = 0.5
    var aperture: Float = 0.0
    var maskDark: Float = 0.5
    var curvature: Float = 0.15
    var cornerRound: Float = 0.1
    
    var vignette: Float = 0.3
    var time: Float = 0.0
    var outModel: Float = 1.0 // 0=None, 1=Aperture Grille, 2=Slot Mask, 3=Dot Triad, 4=B&W
    var hasPersist: Float = 0.0
    
    var bloom: Float = 0.3
    var bloomRad: Float = 0.4
    var halation: Float = 0.0
    var defocus: Float = 0.0
    var grain: Float = 0.0
    
    var outGamma: Float = 1.0
    var outBright: Float = 1.0
    var outContrast: Float = 1.0
    var outSat: Float = 1.0
    var outWarmth: Float = 0.0
    var blackLevel: Float = 0.0
    var whiteClip: Float = 1.0
    
    var phosphor: Float = 0.0
    var hvSag: Float = 0.0
    
    var letterbox: Float = 0.0
    var pillarbox: Float = 0.0
    var bezel: Float = 0.0
    var glassRefl: Float = 0.0
    var dust: Float = 0.0
    var scratches: Float = 0.0
    var ovMoire: Float = 0.0
    var rollShutter: Float = 0.0
    var safeArea: Float = 0.0
    
    var lensDist: Float = 0.0
    var lensCA: Float = 0.0
    var lensStreak: Float = 0.0
    var streakHue: Float = 1.0
    var lensSmudge: Float = 0.0
    
    var lightLeak: Float = 0.0
    var leakHue: Float = 0.0
    var gateWeave: Float = 0.0
    var gateHair: Float = 0.0
    var stuckPix: Float = 0.0
    var lcdGrid: Float = 0.0
    
    var osdShow: Float = 0.0
    var osdGlow: Float = 0.0
    var probe: Float = 0.0
    var rows: Float = 1080.0
}

enum CRTParamID: UInt32 {
    case groupMonitor       = 2001
    case scanlines          = 2002
    case outModel           = 2003
    case maskDark           = 2004
    case curvature          = 2005
    case cornerRound        = 2006
    case vignette           = 2007

    case groupPhosphor      = 2010
    case phosphor           = 2011
    case bloom              = 2012
    case bloomRad           = 2013
    case halation           = 2014

    case groupPicture       = 2020
    case outGamma           = 2021
    case outBright          = 2022
    case outContrast        = 2023
    case outSat             = 2024
    case outWarmth          = 2025
    case whiteClip          = 2026

    case groupOverlays      = 2030
    case bezel              = 2031
    case glassRefl          = 2032
    case dust               = 2033
    case scratches          = 2034
    case grain              = 2035
    case osdShow            = 2036
}
