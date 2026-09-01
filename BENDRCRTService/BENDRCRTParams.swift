import Foundation

struct BENDRCRTParams {
    var ilAmt: Float = 0.0
    var ilMode: Float = 0.0
    var ilOrder: Float = 0.0
    var ilTwitter: Float = 0.4
    var ilJudder: Float = 0.0
    var parity: Float = 0.0
    var time: Float = 0.0

    var phosphor: Float = 0.0
    var phosR: Float = 0.86
    var phosG: Float = 1.0
    var phosB: Float = 0.66

    // CRT Parameters
    var procRes: SIMD2<Float> = SIMD2<Float>(1920, 1080)
    var scanlines: Float = 0.18
    var beamWidth: Float = 1.0
    var beamShape: Float = 0.5
    var aperture: Float = 0.12
    var maskDark: Float = 0.5
    var curvature: Float = 0.3
    var cornerRound: Float = 0.2
    var vignette: Float = 0.35
    var outModel: Float = 0.0
    var hasPersist: Float = 0.0
    
    var bloom: Float = 0.0
    var bloomRad: Float = 0.4
    var halation: Float = 0.0
    var defocus: Float = 0.0
    var grain: Float = 0.0
    
    var outGamma: Float = 1.0
    var outBright: Float = 0.0
    var outContrast: Float = 1.0
    var outSat: Float = 1.0
    var outWarmth: Float = 0.0
    var blackLevel: Float = 0.0
    var whiteClip: Float = 1.0
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
