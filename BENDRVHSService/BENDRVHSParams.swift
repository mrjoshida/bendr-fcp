// BENDRVHSParams.swift — Parameter declarations and state model for BENDR VHS

import Foundation
import FxPlug

struct VHSParams: BendrParams {
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
    var rows: Float = 1080.0
    var vrollpos: Float = 0.0
    var humpos: Float = 0.0
    var rollBar: Float = 0.0
}

enum VHSParamID: UInt32 {
    case groupTape          = 1001
    case tapeSpeed          = 1002
    case tracking           = 1003
    case trackPhase         = 1004
    case trackHunt          = 1005
    case dropout            = 1006
    case dropoutLen         = 1007
    case crease             = 1008
    case creasePos          = 1009
    case headClog           = 1010
    case azimuth            = 1011
    case headSwitch         = 1012
    case tapeWow            = 1013
    case wowRate            = 1014
    case flutter            = 1015
    case tapeStretch        = 1016
    case edgeDmg            = 1017
    case genLoss            = 1018
    case genCount           = 1019

    case groupRF            = 1030
    case chromaBleed        = 1031
    case chromaDelay        = 1032
    case lumaBleed          = 1033
    case bleedDir           = 1034
    case vBleed             = 1035
    case rainbow            = 1036
    case dotCrawl           = 1037
    case ringing            = 1038
    case signalNoise        = 1039
    case chromaNoise        = 1040
    case chromaLoss         = 1041
    case printThru          = 1042
    case hiss               = 1043

    case groupSync          = 1050
    case hWobble            = 1051
    case wobbleFreq         = 1052
    case tear               = 1053
    case tearSize           = 1054
    case vRoll              = 1055
    case jitter             = 1056
    case humBar             = 1057
}
