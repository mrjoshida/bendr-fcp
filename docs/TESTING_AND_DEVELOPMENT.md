# BENDR Developer, Testing & Build Guide

This document explains the development workflow, automated test suites, headless Metal testing, Motion template generation, and debugging strategies for BENDR for Final Cut Pro.

---

## 1. Fast Headless Verification (`Scripts/run_suite.sh`)

You do **not** need Final Cut Pro running to build, test, and visually verify the plugins. All 14 Metal shaders and parameter structs can be verified from the command line in ~3 seconds.

```bash
cd /Users/joshcaldwell/dev/bendr-fcp
./Scripts/run_suite.sh
```

### What `run_suite.sh` executes:
1. **Parameter Struct Memory Alignment Test** (`Scripts/test_struct_alignments.swift`):
   - Validates that Swift struct sizes and field offsets match Metal 8-byte alignment constraints.
2. **Headless GPU Compute Pipeline Execution** (`Scripts/headless_render_test.swift`):
   - Compiles all 14 shaders into a unified Metal library directly on the Apple Silicon GPU.
   - Allocates source, previous, and destination textures and dispatches compute threads.
3. **1080p High-Fidelity Snapshot Verification** (`Scripts/render_snapshots.swift`):
   - Renders 1920×1080 PNG images into `Tests/Outputs/`.
   - Computes non-zero coverage (>70%), pixel delta (>5%), and full dynamic range (0..255).
4. **Motion Template Generator & Installer** (`Scripts/make_templates.py`):
   - Generates `.moef` (Effects) and `.motr` (Transitions) XML templates and installs them into `~/Movies/Motion Templates.localized/`.

---

## 2. Debugging & Common Pitfalls

### A. Metal 8-Byte Struct Padding
- **Problem**: Metal aligns `float2` (or `SIMD2<Float>`) to 8-byte boundaries. If preceded by an odd number of `Float`s, the compiler adds 4 bytes of silent padding.
- **Symptom**: Shader receives shifted values, `res.y` becomes `0.0`, resulting in division by zero (`NaN`) and pure black frames.
- **Solution**: Always test new struct additions with `swift Scripts/test_struct_alignments.swift`.

### B. GPU Unified Memory & WindowServer Watchdog Timeouts
- **Problem**: Passing uninitialized memory (e.g. `0.5f` in a `uint` field) can cause loops to iterate $10^9$ times on the GPU, starving `WindowServer` and triggering a macOS kernel watchdog panic.
- **Solution**: Always enforce hard loop limits in Metal compute kernels (e.g. `uint genCount = min(params.generationCount, 16u);`).

### C. Texture Orientation (OpenGL vs Metal)
- **Problem**: OpenGL texture UV coordinates originate at the bottom-left, whereas Metal / FxPlug texture coordinates originate at the top-left.
- **Solution**: Compute shaders should use standard `(float2(gid) + 0.5) / res`. Do not invert `uv.y` unless explicitly transforming Cartesian mathematical curves.

---

## 3. Building with Xcode & Packaging

```bash
# 1. Install XcodeGen
brew install xcodegen

# 2. Generate Xcode Project
xcodegen generate

# 3. Build All Plugins
xcodebuild -project BENDREffects.xcodeproj -scheme AllPlugins -configuration Release build
```
