// FxPlugExtensions.swift — Swift ergonomics and API bridge for FxPlug 4

import Foundation
import FxPlug
import CoreMedia

extension UnsafeMutablePointer where Pointee == FxScheduleInputsRequest {
    public func addInput(_ inputIndex: UInt32, with time: CMTime) {
        // Schedule input frame at time
    }
}
