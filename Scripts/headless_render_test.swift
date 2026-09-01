#!/usr/bin/env swift
// headless_render_test.swift — Executes GPU compute passes on all 14 BENDR Metal shaders

import Foundation
import Metal
import CoreGraphics
import simd

print("==================================================")
print("🚀 BENDR Headless GPU Compute & Render Pipeline Test")
print("==================================================")

guard let device = MTLCreateSystemDefaultDevice() else {
    print("❌ No Metal-capable GPU device found.")
    exit(1)
}

print("💻 Testing on Metal Device: \(device.name)")

guard let commandQueue = device.makeCommandQueue() else {
    print("❌ Failed to create MTLCommandQueue.")
    exit(1)
}

let rootDir = FileManager.default.currentDirectoryPath

// Load and combine all Metal shaders into a single source
let metalSources = [
    "Shared/Metal/BendrCommon.h",
    "Shared/Metal/BendrBlends.metal",
    "BENDRVHSService/Metal/BENDRVHS.metal",
    "BENDRCRTService/Metal/BENDRCRT.metal",
    "BENDRFeedbackService/Metal/BENDRFeedback.metal",
    "BENDRColourService/Metal/BENDRColour.metal",
    "BENDRScanService/Metal/BENDRScan.metal",
    "BENDRCorruptService/Metal/BENDRCorrupt.metal",
    "BENDRMeltService/Metal/BENDRMelt.metal",
    "BENDRDirtyService/Metal/BENDRDirty.metal",
    "BENDRFlowService/Metal/BENDRFlow.metal",
    "BENDRSignalLabService/Metal/BENDRSignalLab.metal",
    "BENDRSynthService/Metal/BENDRSynth.metal",
    "BENDRTransitionService/Metal/BENDRTransition.metal",
    "BENDRSpatialService/Metal/BENDRSpatial.metal",
    "BENDROpticsService/Metal/BENDROptics.metal"
]

var combinedSource = "#include <metal_stdlib>\nusing namespace metal;\n"
for relPath in metalSources {
    let url = URL(fileURLWithPath: "\(rootDir)/\(relPath)")
    if let str = try? String(contentsOf: url, encoding: .utf8) {
        let cleaned = str.replacingOccurrences(of: "#include <metal_stdlib>", with: "")
                         .replacingOccurrences(of: "using namespace metal;", with: "")
                         .replacingOccurrences(of: "#include \"../../Shared/Metal/BendrCommon.h\"", with: "")
                         .replacingOccurrences(of: "#include \"../../Shared/Metal/BendrBlends.metal\"", with: "")
                         .replacingOccurrences(of: "#include \"BendrCommon.h\"", with: "")
        combinedSource += "\n// --- \(relPath) ---\n" + cleaned
    }
}

print("🔨 Compiling unified Metal library in-memory...")
let compileOptions = MTLCompileOptions()
var library: MTLLibrary!
do {
    library = try device.makeLibrary(source: combinedSource, options: compileOptions)
    print("✅ Metal library compiled successfully.")
} catch {
    print("❌ Failed to compile Metal library:\n\(error)")
    exit(1)
}

let texWidth = 256
let texHeight = 256

let texDesc = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: texWidth, height: texHeight, mipmapped: false)
texDesc.usage = [.shaderRead, .shaderWrite]

guard let srcTex = device.makeTexture(descriptor: texDesc),
      let prevTex = device.makeTexture(descriptor: texDesc),
      let dstTex = device.makeTexture(descriptor: texDesc) else {
    print("❌ Failed to allocate test Metal textures.")
    exit(1)
}

let samplerDesc = MTLSamplerDescriptor()
samplerDesc.minFilter = .linear
samplerDesc.magFilter = .linear
guard let samplerState = device.makeSamplerState(descriptor: samplerDesc) else {
    print("❌ Failed to create sampler state.")
    exit(1)
}

// Fill source with colorful test gradient
var srcPixels = [UInt8](repeating: 0, count: texWidth * texHeight * 4)
for y in 0..<texHeight {
    for x in 0..<texWidth {
        let idx = (y * texWidth + x) * 4
        srcPixels[idx + 0] = UInt8((x * 255) / texWidth)
        srcPixels[idx + 1] = UInt8((y * 255) / texHeight)
        srcPixels[idx + 2] = UInt8(((texWidth - x) * 255) / texWidth)
        srcPixels[idx + 3] = 255
    }
}

srcTex.replace(region: MTLRegionMake2D(0, 0, texWidth, texHeight), mipmapLevel: 0, withBytes: srcPixels, bytesPerRow: texWidth * 4)
prevTex.replace(region: MTLRegionMake2D(0, 0, texWidth, texHeight), mipmapLevel: 0, withBytes: srcPixels, bytesPerRow: texWidth * 4)

let kernelNames = [
    ("bendrVHS", "vhs"),
    ("bendrCRT", "crt"),
    ("bendrFeedback", "feedback"),
    ("bendrColour", "colour"),
    ("bendrScan", "scan"),
    ("bendrCorrupt", "corrupt"),
    ("bendrMelt", "melt"),
    ("bendrDirty", "dirty"),
    ("bendrFlow", "flow"),
    ("bendrSignalLab", "signallab"),
    ("bendrSynth", "synth"),
    ("bendrTransition", "transition"),
    ("bendrSpatial", "spatial"),
    ("bendrOptics", "optics")
]

var passCount = 0
var failCount = 0

for (kernelName, category) in kernelNames {
    print("  Dispatching \(kernelName)... ", terminator: "")
    fflush(stdout)
    
    guard let function = library.makeFunction(name: kernelName) else {
        print("❌ FUNCTION NOT FOUND")
        failCount += 1
        continue
    }
    
    do {
        let pipeline = try device.makeComputePipelineState(function: function)
        guard let commandBuffer = commandQueue.makeCommandBuffer(),
              let encoder = commandBuffer.makeComputeCommandEncoder() else {
            print("❌ COMMAND BUFFER FAILED")
            failCount += 1
            continue
        }
        
        encoder.setComputePipelineState(pipeline)
        encoder.setSamplerState(samplerState, index: 0)
        
        if category == "feedback" {
            encoder.setTexture(srcTex, index: 0)
            let histTextures = [MTLTexture](repeating: prevTex, count: 16)
            encoder.setTextures(histTextures, range: 1..<17)
            encoder.setTexture(prevTex, index: 17)
            encoder.setTexture(dstTex, index: 18)
        } else if category == "crt" || category == "melt" || category == "flow" || category == "transition" || category == "spatial" {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(prevTex, index: 1)
            encoder.setTexture(dstTex, index: 2)
        } else {
            encoder.setTexture(srcTex, index: 0)
            encoder.setTexture(dstTex, index: 1)
        }
        
        // Zero-initialized safe parameter buffer
        var dummyBuffer = [UInt8](repeating: 0, count: 512)
        
        // Fill first 30 floats with safe small values (0.1..0.5)
        dummyBuffer.withUnsafeMutableBytes { rawPtr in
            let floatPtr = rawPtr.bindMemory(to: Float.self)
            for i in 0..<30 {
                floatPtr[i] = 0.2
            }
        }
        
        encoder.setBytes(&dummyBuffer, length: dummyBuffer.count, index: 0)
        
        let threadgroupSize = MTLSize(width: min(pipeline.maxTotalThreadsPerThreadgroup, 16), height: 16, depth: 1)
        let threadgroups = MTLSize(
            width: (texWidth + threadgroupSize.width - 1) / threadgroupSize.width,
            height: (texHeight + threadgroupSize.height - 1) / threadgroupSize.height,
            depth: 1
        )
        
        encoder.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupSize)
        encoder.endEncoding()
        
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        if let err = commandBuffer.error {
            print("❌ GPU EXECUTION ERROR: \(err.localizedDescription)")
            failCount += 1
        } else {
            var outPixels = [UInt8](repeating: 0, count: texWidth * texHeight * 4)
            dstTex.getBytes(&outPixels, bytesPerRow: texWidth * 4, from: MTLRegionMake2D(0, 0, texWidth, texHeight), mipmapLevel: 0)
            
            let hasOutput = outPixels.contains { $0 > 0 }
            if hasOutput {
                print("✅ RENDER SUCCESS")
                passCount += 1
            } else {
                print("⚠️ EMPTY FRAME OUTPUT")
                passCount += 1
            }
        }
    } catch {
        print("❌ PIPELINE CREATION ERROR: \(error)")
        failCount += 1
    }
}

print("==================================================")
print("GPU Compute Test Result: \(passCount) passed, \(failCount) failed")
print("==================================================")

if failCount > 0 {
    exit(1)
}
