# BENDR Suite for Final Cut Pro — Presets Reference Guide

This document provides a comprehensive catalog of all **84 curated presets** included with the BENDR suite for Final Cut Pro, organized across all 14 plugins.

Every preset is available as a drag-and-drop Motion Template in Final Cut Pro under the corresponding **BENDR** category in the Effects and Transitions browsers.

---

## 1. BENDR VHS (`BENDR - VHS`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Broadcast Decay** | Subtle broadcast transmission decay with RF dot crawl, ringing, and line wobble. | `chromaBleed: 0.35`, `dotCrawl: 0.3`, `ringing: 0.35`, `jitter: 0.2`, `genLoss: 0.15` |
| **Chewed Tape** | Physical magnetic tape crease damage, dropout bursts, tracking hunt, and color loss. | `tracking: 0.55`, `trackHunt: 0.6`, `crease: 0.6`, `dropout: 0.5`, `chromaLoss: 0.4` |
| **Dead Deck** | Heavily worn helical transport with head switching noise, dropouts, and dubbing loss. | `chromaBleed: 0.6`, `jitter: 0.5`, `tracking: 0.55`, `headSwitch: 0.8`, `tapeWow: 0.5` |
| **Sync Death** | Horizontal sync hook skew tearing, vertical rolling drift, and line jitter. | `tear: 0.55`, `tearSize: 0.5`, `hWobble: 0.45`, `vRoll: 0.12`, `jitter: 0.6` |
| **Sixth Generation Dub** | Compounded multi-generation tape dubbing loss with heavy tape hiss and ringing. | `tapeSpeed: 0.85`, `genLoss: 0.55`, `genCount: 9.0`, `chromaLoss: 0.5`, `hiss: 0.35` |
| **Head Clog** | Severe tape head clogging, azimuth misalignment, and luma/chroma loss. | `headClog: 0.75`, `azimuth: 0.5`, `tracking: 0.3`, `chromaLoss: 0.6`, `dropout: 0.35` |
| **Dying Spool** | Extreme wow & flutter, stretched tape stock, edge damage, and print-through. | `tapeStretch: 0.7`, `flutter: 0.7`, `wowRate: 0.6`, `edgeDmg: 0.6`, `printThru: 0.5` |
| **Pause Still Frame** | VCR pause mode with helical head still-frame noise and flutter. | `stillNoise: 0.8`, `headSwitch: 0.6`, `tapeStretch: 0.3`, `flutter: 0.4`, `hiss: 0.25` |

---

## 2. BENDR CRT (`BENDR - CRT`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Studio Trinitron** | Precision broadcast production monitor with fine aperture grille. | `outModel: Aperture Grille`, `scanlines: 0.5`, `maskDark: 0.45`, `bloom: 0.25` |
| **CRT Rephoto** | Camera rephotographing curved CRT glass with bloom flare, halation, and defocus. | `bloom: 0.5`, `halation: 0.5`, `defocus: 0.3`, `grain: 0.45`, `curvature: 0.4` |
| **Arcade Slot Mask** | High-contrast arcade coin-op monitor with slot mask phosphor triad. | `outModel: Slot Mask`, `scanlines: 0.65`, `maskDark: 0.6`, `curvature: 0.2`, `bloom: 0.4` |
| **Dot Triad Shadow Mask** | Classic consumer color television delta dot triad screen texture. | `outModel: Dot Triad`, `scanlines: 0.6`, `maskDark: 0.55`, `curvature: 0.25`, `glassRefl: 0.2` |
| **BW Security Monitor** | Monochrome surveillance monitor with persistent phosphor and heavy scanlines. | `outModel: B&W`, `scanlines: 0.75`, `maskDark: 0.4`, `phosphor: 0.3`, `outContrast: 1.3` |
| **Worn Tube Overdrive** | Aged CRT display with intense electron beam scatter and warm halation. | `outModel: Aperture Grille`, `scanlines: 0.4`, `bloom: 0.7`, `halation: 0.6`, `outWarmth: 0.2` |

---

## 3. BENDR Feedback (`BENDR - Feedback`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Droste Tunnel** | Infinite optical corridor feedback tunnel with subtle edge diffusion. | `fbAmount: 0.9`, `fbZoom: 0.2`, `fbBlur: 0.06`, `fbNoise: 0.05`, `fbNL: Tanh` |
| **Rainbow Tunnel** | Recursive feedback loop with rotating spectral HSV hue dispersion. | `fbAmount: 0.92`, `fbZoom: 0.2`, `fbHue: 0.05`, `fbSat: 1.02`, `fbNL: Tanh` |
| **Slow Vortex** | Gentle vortex swirling feedback with chromatic trail drift. | `fbAmount: 0.94`, `fbZoom: 0.05`, `fbRotate: 0.07`, `fbHue: 0.02`, `fbNL: Tanh` |
| **9-Fold Mandala** | Resonant rotational feedback locked into a 9-arm mandala structure. | `fbAmount: 0.94`, `fbZoom: 0.017`, `fbRotate: 0.7`, `fbSharp: 0.3`, `fbNL: Tanh` |
| **Howl-Around** | Classic howling video amplifier overdrive loop with high gain. | `fbAmount: 0.99`, `fbDrive: 3.0`, `fbSharp: 1.0`, `fbNoise: 0.6`, `fbNL: Linear` |
| **Comet Trails** | Luminescent light streaks with directional horizontal shear. | `fbAmount: 0.9`, `fbShiftX: 0.066`, `fbNoise: 0.03`, `fbBlend: Screen` |
| **Turing Labyrinth** | Reaction-diffusion pattern formation using Difference-of-Gaussians filtering. | `fbAmount: 0.97`, `fbBlur: 0.13`, `fbBlur2: 0.4`, `fbSharp: 1.1`, `fbThresh: 0.5` |
| **Cellular Automata** | Organic living cellular feedback structures created by threshold folding. | `fbAmount: 0.96`, `fbZoom: -0.007`, `fbBlur: 0.22`, `fbSharp: 1.2`, `fbThresh: 0.48` |
| **Fire Column** | Upward thermal convection feedback smear with warm fiery gain. | `fbAmount: 0.95`, `fbZoom: -0.04`, `fbShiftY: -0.04`, `fbGainR: 1.15`, `fbGainB: 0.8` |
| **Crystalline Rosette** | High-frequency resonant geometric rosette feedback crystal. | `fbAmount: 0.94`, `fbZoom: 0.033`, `fbRotate: 0.26`, `fbSharp: 1.5` |

---

## 4. BENDR Colour (`BENDR - Colour`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Rainbow Rite** | Sweeping isoline color bands, high saturation, and enhancer glow. | `colorize: 0.85`, `colorBands: 1.8`, `colorSweep: 0.25`, `saturation: 1.3`, `glow: 0.45` |
| **Psych Wash** | Luma-to-chroma cross-synthesis, RGB channel split, and posterization. | `lumaHue: 0.65`, `rgbSep: 0.35`, `invFlick: 0.28`, `saturation: 2.1`, `posterize: 0.3` |
| **Enhancer Burn** | Peaking differentiator overshoot, solarization, and edge ringing. | `rgbSep: 0.22`, `contrast: 1.55`, `saturation: 1.6`, `glow: 0.7`, `solarize: 0.2` |
| **Neon Haze** | Luma-keyed neon glow, chromatic separation, and warm color wash. | `lumaHue: 0.3`, `rgbSep: 0.15`, `colorize: 0.3`, `saturation: 2.0`, `glow: 0.65` |
| **Vol I — Enhancer Lines** | Fine contour isolines, luma quantizer steps, and crisp edge relief. | `contour: 0.95`, `contourBands: 9.0`, `contourWidth: 1.3`, `lumaSteps: 0.55` |
| **Vol II — Colouriser** | Bold psychedelic color banded contours and harmonic wash. | `contour: 0.45`, `contourBands: 9.0`, `colorize: 0.6`, `colorBands: 1.6`, `saturation: 1.7` |
| **Vol III — Full Bend** | High-density contour isolines, 1-bit dither, and heavy RGB split. | `contour: 0.6`, `contourBands: 12.0`, `dither: 0.4`, `colorize: 0.5`, `rgbSep: 0.2` |
| **Lines — Engraving** | Serpentine analog line-delay feedback buffer simulation. | `mline: 1.0`, `mlineGain: 1.2`, `mlineFb: 0.95`, `mlineWin: 40.0`, `contrast: 1.25` |

---

## 5. BENDR Scan (`BENDR - Scan`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Rutt-Etra Raster** | Classic 1970s Rutt-Etra cathode-ray video deflection synthesizer. | `scanLines: 120`, `scanAmt: 0.65`, `scanVel: 0.8`, `scanTiltX: 0.15`, `scanPersp: 0.4` |
| **Oscilloscope Wobble** | High-amplitude sine/LFO beam deflection with Lissajous harmonic modulation. | `scanLines: 80`, `scanAmt: 0.8`, `scanVel: 1.2`, `scanWobAmt: 0.5`, `scanLissa: 0.3` |
| **Paik-Abe Synthesis** | Nam June Paik & Shuya Abe style video synthesizer 3D deflection raster. | `scanLines: 160`, `scanAmt: 0.9`, `scanPersp: 0.6`, `scanTiltX: 0.3`, `scanLissa: 0.4` |
| **Topographic Terrain** | S-curve isometric depth scan mesh creating topographic relief landscape. | `scanLines: 180`, `scanAmt: 0.5`, `scanTiltX: 0.45`, `scanPersp: 0.7`, `scanCurve: 0.35` |
| **Lissajous Beam Crash** | Deflection coil collapse generating intersecting Lissajous figures. | `scanLines: 60`, `scanAmt: 1.2`, `scanWobAmt: 0.8`, `scanLissa: 0.8`, `scanGain: 1.8` |
| **Vertical Slit Deflection**| High line count vertical deflection raster with velocity modulation. | `scanLines: 240`, `scanAmt: 0.7`, `scanVel: 1.4`, `scanPersp: 0.5`, `scanGain: 1.3` |

---

## 6. BENDR Corrupt (`BENDR - Corrupt`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Datamosh Macroblocks** | Macroblock displacement and drift warping simulating dropped P-frames. | `blockShift: 0.75`, `blockSize: 0.45`, `fmWarp: 0.45`, `driftWarp: 0.35` |
| **Pixel Sort Cascade** | Directional luminance threshold scanline pixel sorting cascade. | `pixelSort: 0.9`, `sortThresh: 0.42`, `driftWarp: 0.12` |
| **Halftone Dot Matrix** | High-contrast screen-printing halftone dot matrix rasterization. | `dotify: 0.92`, `dotSize: 0.45` |
| **DCT Quantization Crush**| 8x8 Discrete Cosine Transform high-frequency block quantizer crushing. | `dctAmt: 0.85`, `dctQ: 0.7`, `dctTilt: 0.4`, `dctChroma: 0.8`, `dctBlock: 0.5` |
| **JPEGs Compression Decay**| Aggressive JPEG recompression decay with macroblock shifting. | `blockShift: 0.55`, `blockSize: 0.4`, `dctAmt: 0.9`, `dctQ: 0.85`, `pixelSort: 0.25` |
| **FM Warp Drift** | High-frequency FM coordinate modulation and horizontal shearing. | `fmWarp: 0.7`, `driftWarp: 0.5`, `blockShift: 0.3`, `blockSize: 0.25` |

---

## 7. BENDR Melt (`BENDR - Melt`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Liquid Melt** | Viscous fluid smear and chromatic dispersion along detected edges. | `meltMode: Edge Smear`, `edgeAmt: 1.2`, `edgeHold: 0.85`, `edgeSwirl: 0.5`, `edgeChroma: 0.7` |
| **Gravity Drip** | Downward liquid dripping and trailing edge creep. | `meltMode: Gravity Melt`, `edgeAmt: 1.6`, `edgeHold: 0.92`, `edgeCreep: 0.8`, `edgeChroma: 0.85` |
| **Wet Paint Smear** | Soft lateral paint dispersion with color bleeding. | `meltMode: Edge Smear`, `edgeAmt: 1.8`, `edgeHold: 0.86`, `meltSoft: 0.55`, `edgeChroma: 0.65` |
| **Spiral Melt Vortex** | Centrifugal rotational fluid advection and chromatic swirling. | `meltMode: Spiral Feedback`, `edgeAmt: 1.4`, `edgeHold: 0.9`, `edgeSwirl: 0.6`, `meltZoom: 0.3` |
| **Zoom Bleed Smear** | Radial zoom expansion and highlight color smear. | `meltMode: Motion Driven`, `edgeAmt: 1.5`, `edgeHold: 0.88`, `meltZoom: 0.7`, `edgeChroma: 0.75` |

---

## 8. BENDR Dirty (`BENDR - Dirty`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Crossbar Glitch Fault** | Intermittent video switcher crossbar routing faults and dropouts. | `mixDirt: 0.85`, `mixDirtRate: 0.7`, `mixDirtKnock: 0.6`, `mixDirtDrop: 0.65` |
| **Timebase Knock Jitter** | Timebase corrector synchronization knock and horizontal line shear. | `mixDirt: 0.9`, `mixDirtRate: 0.9`, `mixDirtKnock: 0.95`, `mixDirtDrop: 0.3` |
| **Dropout Storm** | Dense scanline dropout bands and digital switching flashes. | `mixDirt: 0.95`, `mixDirtRate: 0.8`, `mixDirtKnock: 0.4`, `mixDirtDrop: 0.9`, `mixDirtCut: 0.7` |
| **Desk Power Sag** | Analog video console power rail sag, noise bursts, and sync flicker. | `mixDirt: 0.7`, `mixDirtRate: 0.4`, `mixDirtKnock: 0.5`, `mixDirtDrop: 0.5`, `mixDirtNoise: 0.7` |

---

## 9. BENDR Flow (`BENDR - Flow`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Optical Flow Curl Noise**| Multi-scale curl noise turbulent advection vector field. | `flowField: Curl Noise`, `moshVec: 0.85`, `flowGain: 1.8`, `flowCurl: 0.7`, `mosh: 0.3` |
| **Datamosh P-Frame Drag** | Aggressive P-frame motion vector hold and directional shove. | `flowField: Motion`, `mosh: 0.93`, `moshVec: 0.85`, `flowGain: 1.4`, `flowSharp: 0.2` |
| **Contour Vector Crawl** | Flow vector field guided along high-contrast object contours. | `flowField: Contour`, `mosh: 0.9`, `moshVec: 0.7`, `flowCurl: 0.35`, `flowGain: 1.6` |
| **Turbulence Swirl Vortex**| Rotational fluid vortices with dynamic chromatic advection. | `flowField: Spiral`, `swirl: 0.8`, `swirlScale: 0.4`, `swirlSpeed: 0.3`, `flowGain: 1.5` |
| **Vector Trash Block Mosh**| Corrupted macroblock vector trash and motion block displacement. | `flowField: Motion`, `moshBlock: 0.8`, `moshBlockSize: 0.85`, `moshRate: 0.42`, `mosh: 0.6` |

---

## 10. BENDR Signal Lab (`BENDR - Signal Lab`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **1-Bit Bayer Dither Crush**| Vintage 4x4 Bayer matrix ordered dither with monochrome crushing. | `bitCrush: 0.9`, `bitScale: 0.4` |
| **FM Carrier Modulation** | RF carrier frequency modulation synthesis on video scanlines. | `fmAmt: 0.85`, `fmCarrier: 0.4` |
| **Slitscan Time Warp** | Continuous time-domain raster slit scanning displacement. | `slitscan: 0.8`, `slitDir: Horizontal` |
| **PNG Avalanche Glitch** | Lossless PNG predictive filter reconstruction error avalanche. | `pngAmt: 0.85`, `pngRun: 0.6` |
| **NTSC Crosstalk Fringing**| 3.58 MHz color subcarrier crosstalk and high-frequency fringing. | `ntscArt: 0.9`, `ntscFringe: 0.7`, `snow: 0.3`, `snowAniso: 0.5` |
| **Radial Field Warp** | Polar coordinate field synthesis with color phase modulation. | `fieldMod: 0.8`, `fieldSrc: Radial`, `fieldWarp: 0.6`, `fieldHue: 0.4` |

---

## 11. BENDR Synth (`BENDR - Synth`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Starburst FM** | 8-point wavefolded starburst oscillator with quadrature cross-FM. | `shape: Starburst`, `colmode: HSV Spectrum`, `genFM: 0.45`, `genFold: 0.6`, `genFoldN: 8.0` |
| **Spiral Drive** | Rotating wavefolded spiral oscillator with harmonic spectrum mapper. | `shape: Spiral`, `wave: Triangle`, `colmode: HSV Spectrum`, `genFoldN: 6.0`, `genFold: 0.25` |
| **Hard Geometric Shapes** | Analog comparator threshold square wave kaleidoscope pattern. | `shape: Grid`, `wave: Square`, `colmode: Duotone`, `genComp: 1.0`, `genThresh: 0.5` |
| **Plasma Rainbow Bands** | Cross-modulated Lissajous plasma with rainbow harmonic spectrum. | `shape: Plasma`, `colmode: Harmonic Bands`, `genFM: 0.55`, `genBands: 9.0`, `genSpread: 1.6` |
| **Folded Radial Rings** | High-symmetry concentric wavefolded rings with domain warping. | `shape: Radial`, `colmode: RGB Phase`, `genFold: 0.6`, `genWarp: 0.45`, `genSpread: 1.3` |

---

## 12. BENDR Transition (`BENDR - Transitions`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Clock Wipe Highlight** | Radial clock wipe with magenta neon edge highlight line. | `mixMode: Clock Wipe`, `wipeBord: 0.75`, `wipeBordCol: 0.5`, `wipeSoft: 0.03` |
| **Checkerboard Dissolve** | Multi-block alternating checkerboard matrix transition. | `mixMode: Checker Wipe`, `wipeRep: 4.0`, `wipeSoft: 0.05` |
| **Noise Scatter Wipe** | High-frequency random noise scatter wipe dissolve. | `mixMode: Noise Wipe`, `wipeSoft: 0.2`, `wipeDetail: 0.6` |
| **Luma Keyer Burn In** | Highlight luminance threshold key transition with soft border. | `mixMode: Cross Dissolve`, `mixKey: White Key`, `mixKeyThresh: 0.5`, `mixKeySoft: 0.2` |
| **Slide Push Edge Line** | Directional slide push with highlighted seam border. | `mixMode: Slide Left`, `wipeBord: 0.8`, `wipeBordCol: 0.2` |

---

## 13. BENDR Spatial (`BENDR - Spatial`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **80s Triangle Kaleidoscope**| 3-fold triangular kaleidoscopic mirror symmetry fold. | `kaleido: 1.0`, `kaleidoN: 3.0`, `kaleidoRot: 0.15`, `srcZoom: 0.15` |
| **Blade Runner Hexagon Fold**| 6-fold radial kaleidoscope with rotation and zoom. | `kaleido: 1.0`, `kaleidoN: 6.0`, `kaleidoRot: -0.1`, `srcZoom: 0.2` |
| **4x4 Video Wall Grid** | Multi-screen 16-tile array matrix video wall. | `multiN: 4.0`, `srcZoom: 0.0` |
| **Time Displacement Warp** | Luminance-driven temporal mapping and displacement warp. | `tdAmt: 0.7`, `tdMap: Luma Map`, `tdSpread: 0.8`, `tdSoft: 1.0`, `tdWarp: 0.3` |
| **Camera Shake and Drift** | Dynamic handheld camera jitter, shake, and rotation drift. | `shake: 0.6`, `shakeRate: 1.5`, `srcZoom: 0.1` |

---

## 14. BENDR Optics (`BENDR - Optics`)

| Preset Name | Description | Key Dialed Parameters |
|---|---|---|
| **Retro Camcorder HUD** | Authentic VHS camcorder OSD (REC dot + battery + timecode) and lens flare. | `osdShow: 1.0`, `osdGlow: 0.7`, `lensCA: 0.4`, `vignette: 0.4`, `grain: 0.2` |
| **Anamorphic Blue Streak and Bloom**| Horizontal anamorphic flare streak on highlights with optical bloom. | `lensStreak: 0.85`, `streakHue: 0.6`, `bloom: 0.65`, `halation: 0.5`, `vignette: 0.4` |
| **Vintage Film Halation and Grain**| Warm red film halation, heavy stock grain, scratches, and light leaks. | `halation: 0.85`, `bloom: 0.4`, `grain: 0.4`, `lightLeak: 0.4`, `scratches: 0.35` |
| **Dirty Glass and Flare** | Smudged front lens element, warm edge light leak, and vignette. | `lensSmudge: 0.7`, `lightLeak: 0.6`, `bloom: 0.5`, `vignette: 0.45` |
| **Heavy Chromatic Aberration**| Extreme radial red-cyan optical dispersion and edge fringing. | `lensCA: 0.9`, `lensStreak: 0.3`, `vignette: 0.5`, `grain: 0.15` |
