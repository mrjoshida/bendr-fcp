# BENDR for Final Cut Pro — Architecture & Technical Guide

This document details the architectural design, memory conventions, and rendering lifecycle of the BENDR FxPlug 4 plugin suite for Final Cut Pro.

---

## 1. Out-of-Process XPC Plugin Model (FxPlug 4)

Apple deprecated in-process plugins in macOS Catalina. FxPlug 4 operates strictly as an **Out-of-Process (OOP)** architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Final Cut Pro Host                       │
│  - Timeline & Playhead Management                           │
│  - Parameter UI Rendering (Inspector)                       │
│  - Image Buffer Allocation via IOSurface                    │
└──────────────────────────────┬──────────────────────────────┘
                               │
                      Mach XPC Channel
                               │
┌──────────────────────────────▼──────────────────────────────┐
│             BENDR XPC Service (.xpc / .appex)               │
│  - Protocol: FxTileableEffect                               │
│  - Parameter Encoding: FxParameterRetrievalAPI_v6           │
│  - Metal Compute Pipeline & Shaders                         │
│  - Zero-Copy IOSurface Texture Binding                      │
└─────────────────────────────────────────────────────────────┘
```

### Key Rules:
1. **Container App Wrapping**: Every XPC service must reside inside an enclosing macOS Application (`.app`) bundle under `Contents/PlugIns/` or `Contents/XPCServices/`.
2. **PlugInKit Registration**: When the container application is launched or moved into `/Applications`, macOS PlugInKit discovers and registers the plugin UUIDs with Final Cut Pro and Motion.
3. **Zero-Copy IOSurface Sharing**: Video frames are backed by hardware `IOSurface` handles shared between FCP and the XPC process. Metal textures are created directly from these surfaces without CPU memory copying.

---

## 2. Memory Alignment & Struct Layout (Swift vs MSL)

Metal Shading Language (MSL) requires strict alignment matching the Apple Silicon GPU ABI. 

> [!IMPORTANT]
> **The 8-Byte Alignment Rule**:
> Any `float2` (or `SIMD2<Float>`) in Metal must align on an **8-byte boundary**. If preceded by an odd number of 32-bit `Float` values, the Metal compiler inserts **4 bytes of silent padding**.

### Example:
```metal
// MSL Struct
struct MyParams {
    float time;       // Offset 0  (4 bytes)
    // [4 BYTES PADDING INSERTED HERE BY COMPILER]
    float2 res;       // Offset 8  (8 bytes)
};                    // Total size = 16 bytes
```

### Best Practice:
1. Always declare parameters using **typed Swift structs conforming to `BendrParams`** with matching types (`Float`, `SIMD2<Float>`, `UInt32`).
2. Never index raw flat `[Float]` arrays across `float2` boundaries without accounting for padding.
3. Validate memory layout using `MemoryLayout<T>.stride` and `Scripts/test_struct_alignments.swift`.

---

## 3. Stateless & Historical Frame Scheduling

Final Cut Pro rendering is inherently **stateless** (render nodes can be called out-of-order, in reverse, or on background threads). To perform feedback, melting, or optical flow:

### `scheduleInputs(_:with:at:)`
Plugins request preceding frames dynamically along the timeline:
```swift
public func scheduleInputs(_ request: inout FxScheduleInputsRequest, with pluginState: Data?, at time: CMTime) throws {
    // Input 0 = Current time
    request.addInput(0, with: time)
    
    // Request up to 16 historical frames for feedback
    let frameDuration = CMTime(value: 1001, timescale: 30000)
    for i in 1...16 {
        let histTime = CMTimeSubtract(time, CMTimeMultiply(frameDuration, multiplier: Int32(i)))
        request.addInput(0, with: histTime)
    }
}
```

---

## 4. Shared Metal Infrastructure

Common utilities are centralized under `Shared/Metal/`:
- `BendrCommon.h`: Hash functions (`h21`), color space transforms (`rgb2yiq`, `yiq2rgb`, `rgb2hsv`, `hsv2rgb`), luminance (`lum3`), and hardware keying (`keyOf`).
- `BendrBlends.metal`: 24 hardware video mixer blend modes (Add, Multiply, Screen, Difference, Grain Extract, Hard Light, etc.).
- `BendrMetalContext.swift`: Thread-safe per-GPU device, command queue, and pipeline state caching.
