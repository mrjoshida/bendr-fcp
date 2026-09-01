// BendrTexturePool.swift — Reusable intermediate texture allocator
// Avoids per-frame MTLTexture allocation overhead during multi-pass rendering

import Metal
import Foundation

/// A pool of reusable Metal textures for intermediate render passes.
/// Created per-render-call and drained afterwards. Textures are recycled
/// between render calls when dimensions match.
final class BendrTexturePool {

    private var available: [MTLTexture] = []
    private let lock = NSLock()

    /// Acquire a texture matching the given dimensions and format.
    /// Returns a recycled texture if one matches, otherwise creates a new one.
    func acquire(device: MTLDevice,
                 width: Int,
                 height: Int,
                 format: MTLPixelFormat = .bgra8Unorm,
                 usage: MTLTextureUsage = [.shaderRead, .shaderWrite]) -> MTLTexture? {
        lock.lock()
        defer { lock.unlock() }

        // Look for a matching recycled texture
        if let idx = available.firstIndex(where: {
            $0.width == width && $0.height == height && $0.pixelFormat == format
        }) {
            let tex = available.remove(at: idx)
            return tex
        }

        // Create a new texture
        let desc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: format,
            width: width,
            height: height,
            mipmapped: false
        )
        desc.usage = usage
        desc.storageMode = .private  // GPU-only for intermediates
        return device.makeTexture(descriptor: desc)
    }

    /// Acquire a float16 texture (used for HDR intermediates like scan processor accumulation)
    func acquireFloat16(device: MTLDevice, width: Int, height: Int) -> MTLTexture? {
        return acquire(device: device, width: width, height: height,
                       format: .rgba16Float, usage: [.shaderRead, .shaderWrite, .renderTarget])
    }

    /// Return a texture to the pool for reuse.
    func release(_ texture: MTLTexture) {
        lock.lock()
        defer { lock.unlock() }
        available.append(texture)
    }

    /// Release all pooled textures. Call between render operations
    /// if memory pressure is a concern.
    func drain() {
        lock.lock()
        defer { lock.unlock() }
        available.removeAll()
    }

    /// Current number of pooled textures
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return available.count
    }
}
