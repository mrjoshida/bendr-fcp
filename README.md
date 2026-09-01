# BENDR Effects for Final Cut Pro

FxPlug 4 plugin suite porting [BENDR](https://bendr.allmyfriendsaresynths.com)'s circuit-bent video processing to Final Cut Pro.

## Plugins (Phase 1 — P0)

| Plugin | Type | Description |
|--------|------|-------------|
| **BENDR VHS** | Filter | VHS tape degradation, NTSC composite signal artifacts, sync corruption |
| **BENDR CRT** | Filter | CRT monitor emulation: scanlines, shadow masks, barrel distortion, phosphor, overlays |
| **BENDR Feedback** | Filter | Recursive video feedback tunnels with spatial/color transforms |

## Requirements

- **macOS 13.0+** (Ventura or later)
- **Xcode 16+** with Metal support
- **Final Cut Pro** (provides the FxPlug 4 framework)
- **Apple Motion** (for creating Motion Templates — required for FCP integration)
- **XcodeGen** (`brew install xcodegen`)

## Building

```bash
# 1. Install XcodeGen if you haven't
brew install xcodegen

# 2. Generate the Xcode project
cd bendr-fcp
xcodegen generate

# 3. Build all plugins
xcodebuild -project BENDREffects.xcodeproj \
           -scheme AllPlugins \
           -configuration Release \
           build

# 4. Run each wrapper app once to register with PlugInKit
open build/Release/BENDRVHSApp.app
open build/Release/BENDRCRTApp.app
open build/Release/BENDRFeedbackApp.app
```

## Creating Motion Templates

After building and registering the plugins, create Motion Templates so they appear in FCP:

1. Open **Apple Motion**
2. File → New → Final Cut Effect
3. In the Library, find your BENDR plugin under Filters
4. Drag it onto the Effect Source layer
5. Select the filter in the Layers panel
6. In the Inspector, right-click each parameter → **Publish**
7. File → Save As Template → Category: "BENDR"
8. Repeat for each plugin

The templates will appear in FCP's Effects Browser under the "BENDR" category.

## Project Structure

```
bendr-fcp/
├── project.yml              # XcodeGen project specification
├── Shared/                  # Code shared across all plugins
│   ├── Metal/
│   │   ├── BendrCommon.h    # MSL utilities: hash, YIQ, HSV, keyer
│   │   └── BendrBlends.metal # 24 blend modes
│   ├── BendrMetalContext.swift   # Per-GPU device/pipeline cache
│   ├── BendrTexturePool.swift    # Intermediate texture recycling
│   ├── BendrPluginState.swift    # Parameter snapshot serialization
│   └── BendrRenderHelpers.swift  # Compute dispatch utilities
│
├── BENDRVHSApp/             # VHS wrapper application
├── BENDRVHSService/         # VHS XPC service (Metal shaders + Swift)
├── BENDRCRTApp/             # CRT wrapper application
├── BENDRCRTService/         # CRT XPC service
├── BENDRFeedbackApp/        # Feedback wrapper application
└── BENDRFeedbackService/    # Feedback XPC service
```

## Architecture

Each plugin is an **FxPlug 4 out-of-process XPC service** wrapped in a macOS application:

- The wrapper app registers the plugin with macOS PlugInKit
- The XPC service contains the FxTileableEffect implementation and Metal shaders
- Frame data transfers via IOSurface (zero-copy between FCP and plugin)
- All rendering is done via Metal compute shaders
- Rendering is **stateless** — no persistent GPU state between frames

## Porting from BENDR

The BENDR source GLSL shaders are ported to Metal Shading Language (MSL). Key differences:

- WebGL2 GLSL → MSL compute kernels (no vertex/fragment, just compute dispatch)
- Browser's `requestAnimationFrame` render loop → FxPlug's on-demand `renderDestinationImage`
- Persistent feedback textures → Temporal multi-sampling via `scheduleInputs`
- HTML/CSS parameter UI → FxPlug parameter inspector (keyframeable)

## License

Same license as the BENDR source project.
