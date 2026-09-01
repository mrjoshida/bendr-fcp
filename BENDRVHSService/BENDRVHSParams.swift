import Foundation

struct BENDRVHSParams {
    var chromaBleed: Float = 0.25
    var chromaDelay: Float = 0.0
    var lumaBleed: Float = 0.0
    var bleedDir: Float = 0.5
    var vBleed: Float = 0.0
    var rainbow: Float = 0.1
    var dotCrawl: Float = 0.1
    var ringing: Float = 0.15
    var signalNoise: Float = 0.05
    var chromaNoise: Float = 0.05
    
    var hWobble: Float = 0.05
    var wobbleFreq: Float = 0.2
    var tear: Float = 0.0
    var tearSize: Float = 0.4
    var vRoll: Float = 0.0
    var jitter: Float = 0.1
    var humBar: Float = 0.1
    
    var tapeSpeed: Float = 0.0
    var tracking: Float = 0.0
    var trackPhase: Float = 0.0
    var trackHunt: Float = 0.0
    var dropout: Float = 0.0
    var dropoutLen: Float = 0.35
    var chromaLoss: Float = 0.0
    var crease: Float = 0.0
    var creasePos: Float = 0.5
    var headClog: Float = 0.0
    var azimuth: Float = 0.0
    var headSwitch: Float = 0.3
    var tapeWow: Float = 0.15
    var wowRate: Float = 0.25
    var flutter: Float = 0.0
    var tapeStretch: Float = 0.0
    var edgeDmg: Float = 0.0
    var printThru: Float = 0.0
    var hiss: Float = 0.0
    var stillNoise: Float = 0.0
    var shuttleNz: Float = 0.0
    var genLoss: Float = 0.1
    var genCount: Float = 1.0

    // Hidden globals needed by shader
    var time: Float = 0.0
    var frame: Float = 0.0
    var rows: Float = 576.0
    var vrollpos: Float = 0.0
    var humpos: Float = 0.0
    var rollBar: Float = 0.0
}
