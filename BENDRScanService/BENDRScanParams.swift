// BENDRScanParams.swift — Parameter declarations and state model for BENDR Scan

import Foundation
import FxPlug

struct ScanParams: BendrParams {
    var lines: Float = 320.0
    var samples: Float = 256.0
    var scanAmt: Float = 0.5
    var scanWidth: Float = 0.12
    var scanVel: Float = 0.8
    var scanTiltX: Float = 0.0
    var scanTiltY: Float = 0.0
    var scanPersp: Float = 0.3
    var scanCurve: Float = 0.0
    var scanCollapse: Float = 0.0
    var scanRevH: Float = 0.0
    var scanRevV: Float = 0.0
    var scanWobAmt: Float = 0.0
    var scanWobFreq: Float = 0.25
    var scanWobLock: Float = 1.0
    var scanLissa: Float = 0.0
    var scanSkew: Float = 0.0
    var scanGain: Float = 1.0
    var scanMono: Float = 0.0
    var scanHue: Float = 0.0
    var time: Float = 0.0
}

enum ScanParamID: UInt32 {
    case groupDeflection = 5001
    case scanAmt         = 5002
    case scanLines       = 5003
    case scanSamples     = 5004
    case scanWidth       = 5005
    case scanVel         = 5006
    case scanGain        = 5007

    case group3D         = 5010
    case scanTiltX       = 5011
    case scanTiltY       = 5012
    case scanPersp       = 5013
    case scanCurve       = 5014
    case scanSkew        = 5015
    case scanCollapse    = 5016

    case groupModulation = 5020
    case scanWobAmt      = 5021
    case scanWobFreq     = 5022
    case scanWobLock     = 5023
    case scanLissa       = 5024
    case scanRevH        = 5025
    case scanRevV        = 5026

    case groupColor      = 5030
    case scanMono        = 5031
    case scanHue         = 5032
}
