// BENDRSynthParams.swift — Parameter declarations and state model for BENDR Synth

import Foundation
import FxPlug

struct SynthParams: BendrParams {
    var shape: Float = 0.0         // 0: Scan, 1: Radial, 2: Spiral, 3: Plasma, 4: Lissajous, 5: Rings, 6: Starburst, 7: Grid, 8: Tunnel, 9: Cells, 10: Interference, 11: Polygon
    var wave: Float = 0.0          // 0: Sine, 1: Triangle, 2: Saw, 3: Square, 4: Pulse, 5: Noise
    var colmode: Float = 2.0       // 0: Monochrome, 1: RGB Phase, 2: HSV Spectrum, 3: Duotone, 4: Harmonic Bands

    var genFreqX: Float = 0.18     // Frequency X (0..1)
    var genFreqY: Float = 0.12     // Frequency Y (0..1)
    var genPhase: Float = 0.0      // Oscillator phase (-1..1)
    var genRate: Float = 0.08      // Animation rate (-1..1)
    var genRot: Float = 0.0        // Coordinate rotation (-1..1)
    var genSkew: Float = 0.0       // Raster skew (-1..1)

    var genFM: Float = 0.0         // Cross-Modulation / FM depth (0..1)
    var genPulse: Float = 0.5      // Pulse width (0..1)
    var genFold: Float = 0.0       // Wavefolder depth (0..1)
    var genComp: Float = 0.0       // Analog comparator level (0..1)
    var genThresh: Float = 0.5     // Comparator threshold (0..1)
    var genSoft: Float = 0.12      // Comparator softness (0..1)

    var genFoldN: Float = 4.0      // Symmetry folds (1..16)
    var genCX: Float = 0.0         // Center X (-1..1)
    var genCY: Float = 0.0         // Center Y (-1..1)
    var genZoom: Float = 0.0       // Scale / Zoom (-1..1)
    var genWarp: Float = 0.0       // Domain warp (0..1)

    var genHue: Float = 0.55       // Base color hue (0..1)
    var genSpread: Float = 1.0     // Color spread (0..2)
    var genSat: Float = 0.9        // Saturation (0..1)
    var genBright: Float = 1.0     // Brightness gain (0..1.5)
    var genBands: Float = 6.0      // Color band count (2..16)

    var blendWithSource: Float = 0.0 // 0: Generator output, >0: Overlaid on input video

    var time: Float = 0.0
    var res: SIMD2<Float> = SIMD2<Float>(1920.0, 1080.0)
}

enum SynthParamID: UInt32 {
    case groupGeometry     = 10001
    case shape             = 10002
    case wave              = 10003
    case genFreqX          = 10004
    case genFreqY          = 10005
    case genPhase          = 10006
    case genRate           = 10007
    case genRot            = 10008
    case genSkew           = 10009
    case genCX             = 10010
    case genCY             = 10011
    case genZoom           = 10012
    case genFoldN          = 10013

    case groupModulation   = 10020
    case genFM             = 10021
    case genFold           = 10022
    case genPulse          = 10023
    case genComp           = 10024
    case genThresh         = 10025
    case genSoft           = 10026
    case genWarp           = 10027

    case groupColor        = 10030
    case colmode           = 10031
    case genHue            = 10032
    case genSpread         = 10033
    case genSat            = 10034
    case genBright         = 10035
    case genBands          = 10036
    case blendWithSource   = 10037
}
