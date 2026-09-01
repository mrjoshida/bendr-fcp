// BendrMetalContext.swift — Per-GPU Metal device, command queue, and pipeline state cache
// Shared across all BENDR FxPlug plugins

import Metal
import Foundation

/// Manages Metal device state per GPU. FxPlug images can arrive on different GPUs
/// (e.g. Mac Pro, eGPU), so we cache a context per device registry ID.
final class BendrMetalContext {

    let device: MTLDevice
    let commandQueue: MTLCommandQueue

    private var computePipelines: [String: MTLComputePipelineState] = [:]
    private var renderPipelines: [String: MTLRenderPipelineState] = [:]
    private let lock = NSLock()

    // --- Per-device context cache ---
    private static var contexts: [UInt64: BendrMetalContext] = [:]
    private static let contextLock = NSLock()

    /// Returns the cached context for the given device registry ID, creating one if needed.
    static func context(for registryID: UInt64) -> BendrMetalContext? {
        contextLock.lock()
        defer { contextLock.unlock() }

        if let cached = contexts[registryID] {
            return cached
        }

        // Find the MTLDevice matching this registry ID
        guard let device = MTLCopyAllDevices().first(where: { $0.registryID == registryID }),
              let queue = device.makeCommandQueue()
        else {
            return nil
        }

        let ctx = BendrMetalContext(device: device, commandQueue: queue)
        contexts[registryID] = ctx
        return ctx
    }

    private init(device: MTLDevice, commandQueue: MTLCommandQueue) {
        self.device = device
        self.commandQueue = commandQueue
    }

    // --- Compute pipeline cache ---

    /// Returns a cached compute pipeline for the named kernel function.
    func computePipeline(named name: String) throws -> MTLComputePipelineState {
        lock.lock()
        defer { lock.unlock() }

        if let cached = computePipelines[name] {
            return cached
        }

        guard let library = try? device.makeDefaultLibrary(bundle: Bundle(for: type(of: self))),
              let function = library.makeFunction(name: name)
        else {
            // Fallback: try the main bundle
            guard let library = device.makeDefaultLibrary(),
                  let function = library.makeFunction(name: name)
            else {
                throw BendrError.shaderNotFound(name)
            }
            let pipeline = try device.makeComputePipelineState(function: function)
            computePipelines[name] = pipeline
            return pipeline
        }

        let pipeline = try device.makeComputePipelineState(function: function)
        computePipelines[name] = pipeline
        return pipeline
    }

    /// Returns a cached compute pipeline for a function from a specific library.
    func computePipeline(named name: String, from library: MTLLibrary) throws -> MTLComputePipelineState {
        lock.lock()
        defer { lock.unlock() }

        let cacheKey = "\(library.label ?? "lib")_\(name)"
        if let cached = computePipelines[cacheKey] {
            return cached
        }

        guard let function = library.makeFunction(name: name) else {
            throw BendrError.shaderNotFound(name)
        }

        let pipeline = try device.makeComputePipelineState(function: function)
        computePipelines[cacheKey] = pipeline
        return pipeline
    }

    // --- Render pipeline cache ---

    /// Returns a cached render pipeline for the given descriptor key.
    func renderPipeline(key: String, descriptor: MTLRenderPipelineDescriptor) throws -> MTLRenderPipelineState {
        lock.lock()
        defer { lock.unlock() }

        if let cached = renderPipelines[key] {
            return cached
        }

        let pipeline = try device.makeRenderPipelineState(descriptor: descriptor)
        renderPipelines[key] = pipeline
        return pipeline
    }

    // --- Command buffer helpers ---

    /// Creates a new command buffer. Returns nil on failure.
    func makeCommandBuffer() -> MTLCommandBuffer? {
        return commandQueue.makeCommandBuffer()
    }
}

// --- Error types ---
enum BendrError: Error, LocalizedError {
    case shaderNotFound(String)
    case textureCreationFailed
    case commandBufferFailed
    case renderFailed(String)

    var errorDescription: String? {
        switch self {
        case .shaderNotFound(let name):
            return "BENDR: Metal shader function '\(name)' not found"
        case .textureCreationFailed:
            return "BENDR: Failed to create intermediate texture"
        case .commandBufferFailed:
            return "BENDR: Failed to create command buffer"
        case .renderFailed(let reason):
            return "BENDR: Render failed — \(reason)"
        }
    }
}
