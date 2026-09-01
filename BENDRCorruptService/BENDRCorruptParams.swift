import Foundation

struct CorruptParams: Codable {
    var pixelSort: Float = 0.0
    var sortThresh: Float = 0.45
    var blockShift: Float = 0.0
    var blockSize: Float = 0.35
    var dotify: Float = 0.0
    var dotSize: Float = 0.4
    var driftWarp: Float = 0.0
    var fmWarp: Float = 0.0
    var dctAmt: Float = 0.0
    var dctQ: Float = 0.25
    var dctTilt: Float = 0.5
    var dctChroma: Float = 0.4
    var dctBlock: Float = 0.35
    var time: Float = 0.0
}
