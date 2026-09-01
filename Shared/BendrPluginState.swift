// BendrPluginState.swift — Generic parameter snapshot encoding/decoding
// FxPlug requires all parameters to be packed into NSData in pluginState(at:)
// and unpacked in renderDestinationImage. This provides the serialization layer.

import Foundation

/// Protocol for plugin-specific parameter structs.
/// Each plugin defines its own Params struct conforming to this.
protocol BendrParams: Codable {
    /// Encode this parameter snapshot into Data for FxPlug's pluginState
    func encode() throws -> Data

    /// Decode a parameter snapshot from FxPlug's pluginState Data
    static func decode(from data: Data) throws -> Self
}

extension BendrParams {
    func encode() throws -> Data {
        return try JSONEncoder().encode(self)
    }

    static func decode(from data: Data) throws -> Self {
        return try JSONDecoder().decode(Self.self, from: data)
    }
}

/// Common parameter group IDs used across plugins
/// FxPlug parameter IDs must be positive integers 1–9998
enum BendrParamGroup {
    // Reserve ID ranges per plugin to avoid collisions
    // Each plugin uses a 1000-wide range
    static let vhsBase       = 1000
    static let crtBase        = 2000
    static let feedbackBase   = 3000
    static let colourBase     = 4000
    static let scanBase       = 5000
    static let corruptBase    = 6000
    static let flowBase       = 7000
    static let signalLabBase  = 8000
    static let meltBase       = 9000
    static let dirtyBase      = 9500
}
