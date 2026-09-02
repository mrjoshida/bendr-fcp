# BENDR Plugin Suite — Parameter & Algorithm Reference

This document provides a comprehensive reference for all 14 plugins in the BENDR suite for Final Cut Pro, including their mathematical foundations, UI controls, parameter ranges, and default values.

---

## 1. BENDR VHS
**Type**: Filter | **Service**: `BENDRVHSService` | **Kernel**: `bendrVHS`
Emulates analog magnetic tape degradation, NTSC/PAL composite signal decoding, phase errors, and servo tracking drift.

### Parameters:
- **Composite Signal**:
  - `chromaBleed` (0..1, def 0.25): 9-tap non-wrapping horizontal color smearing.
  - `chromaDelay` (-1..1, def 0.0): Horizontal time offset of chroma relative to luma.
  - `lumaBleed` (0..1, def 0.0): Directional luminance smearing across scanlines.
  - `rainbow` (0..1, def 0.1): NTSC color subcarrier cross-talk on sharp high-contrast edges.
  - `dotCrawl` (0..1, def 0.1): Subcarrier interference pattern along vertical edges.
  - `ringing` (0..1, def 0.15): High-frequency peaking filter edge overshoot.
  - `signalNoise` / `chromaNoise` (0..1, def 0.05): Separate luma and chroma tape noise.
- **Sync & Tracking**:
  - `hWobble` / `wobbleFreq` (0..1, def 0.05/0.2): Horizontal line jitter and frequency.
  - `tear` / `tearSize` (0..1, def 0.0/0.4): Top-of-frame sync hook and skew tearing.
  - `headSwitch` (0..1, def 0.3): Bottom-of-frame helical head switching band noise.
  - `genLoss` / `genCount` (0..1/1..12, def 0.1/1.0): Exponential multi-generation dubbing loss.

---

## 2. BENDR CRT
**Type**: Filter | **Service**: `BENDRCRTService` | **Kernel**: `bendrCRT`
Emulates classic cathode-ray tube displays, Trinitron aperture grilles, shadow masks, electron beam bloom, and curved glass bezels.

### Parameters:
- **Monitor Geometry**:
  - `curvature` (0..1, def 0.15): Barrel distortion curvature of the glass envelope.
  - `cornerRound` (0..1, def 0.1): Bezel corner radius rounding.
  - `vignette` (0..1, def 0.3): Radial falloff of screen illumination.
- **Beam & Mask**:
  - `outModel` (0..4, def 1.0): Shadow mask mode (0=None, 1=Aperture Grille/Trinitron, 2=Slot Mask, 3=Dot Triad, 4=B&W).
  - `scanlines` (0..1, def 0.5): Gaussian electron beam raster line density.
  - `beamWidth` / `beamShape` (0.1..3.0, def 1.0/0.5): Dynamic luma-dependent scanline beam width.
  - `maskDark` (0..1, def 0.5): Darkness of phosphor separation gaps.
- **Phosphor & Optics**:
  - `bloom` / `bloomRad` (0..1, def 0.3/0.4): High-luma electron beam scattering into adjacent phosphors.
  - `halation` (0..1, def 0.0): Warm orange/red internal glass reflection flare.
  - `glassRefl` (0..1, def 0.0): Ambient room light glare on curved glass surface.

---

## 3. BENDR Feedback
**Type**: Filter | **Service**: `BENDRFeedbackService` | **Kernel**: `bendrFeedback`
Simulates infinite optical and electronic video feedback loops (pointing a camera at a monitor).

### Parameters:
- **Transform**:
  - `fbAmount` (0..0.99, def 0.0): Feedback loop recirculation gain.
  - `fbZoom` (-1..1, def 0.0): Optical zoom magnification per loop iteration.
  - `fbRotate` (-1..1, def 0.0): Angular rotation per loop iteration.
  - `fbHue` (0..1, def 0.0): HSV hue shift per loop iteration.
  - `fbShearX` / `fbShearY` (-1..1, def 0.0): Perspective skew distortion.
- **Dynamics & Transfer Curves**:
  - `fbDrive` (0.2..4.0, def 1.0): Non-linear amplifier overdrive.
  - `fbNL` (0..3, def 0.0): Non-linear transfer curve (0=Linear, 1=Hyperbolic Tangent, 2=Modulo Saw, 3=Triangle Fold).
  - `fbBlur` / `fbBlur2` / `fbSharp` (0..2, def 0.0): Difference-of-Gaussians bandpass filtering.

---

## 4. BENDR Colour
**Type**: Filter | **Service**: `BENDRColourService` | **Kernel**: `bendrColour`
Broadcast video-mixer color stage, bent enhancer isolines, differentiators, and delay-line feedback.

### Parameters:
- **Color Stage**: `rGain`, `gGain`, `bGain`, `saturation`, `hue`, `brightness`, `contrast`.
- **Special Effects**: `posterize`, `solarize`, `negative`, `monoCol`, `colorPass`, `silhouette`, `glow`.
- **Relief & Edge**: `findEdge`, `emboss`, `diffAmt`, `diffScale`, `diffPolar`, `ampAmt` (classifier).
- **Bent Enhancer**: `colorize`, `colorBands`, `colorSweep`, `sharpEcho`, `rgbSep`.
- **Modulation Lines (`mline`)**: Analog serpentine line-delay feedback buffer simulation (`mlineGain`, `mlineFb`, `mlineWin`).

---

## 5. BENDR Scan
**Type**: Filter | **Service**: `BENDRScanService` | **Kernel**: `bendrScan` / `scanVertex`
Rutt-Etra and Paik-Abe style video synthesizer cathode ray beam deflection in 3D space.

### Parameters:
- **Raster Deflection**: `scanAmt`, `scanLines` (60..720), `scanSamples` (64..640), `scanWidth`, `scanVel` (velocity modulation gain), `scanGain`.
- **3D Geometry**: `scanTiltX`, `scanTiltY`, `scanPersp`, `scanCurve` (S-curve), `scanSkew`, `scanCollapse`.
- **Modulation**: `scanWobAmt`, `scanWobFreq`, `scanWobLock`, `scanLissa` (Lissajous figure), `scanRevH`, `scanRevV`.

---

## 6. BENDR Corrupt
**Type**: Filter | **Service**: `BENDRCorruptService` | **Kernel**: `bendrCorrupt`
Directional pixel sorting, DCT 8×8 macroblock quantization compression artifacts, and halftone dotting.

### Parameters:
- `pixelSort` / `sortThresh` (0..1, def 0.0/0.45): Directional threshold sorting of scanline pixel runs.
- `blockShift` / `blockSize` (0..1, def 0.0/0.35): Random macroblock translation offsets.
- `dotify` / `dotSize` (0..1, def 0.0/0.4): Halftone screen matrix simulation.
- `dctAmt` / `dctQ` / `dctBlock` (0..1, def 0.0/0.25/0.35): 8×8 Discrete Cosine Transform quantization crushing.

---

## 7. BENDR Melt
**Type**: Filter | **Service**: `BENDRMeltService` | **Kernel**: `bendrMelt`
Liquid analog video feedback smear, edge detection gravity dripping, and chromatic dispersion.

### Parameters:
- `meltMode` (0..3, def 0.0): 0=Edge Smear, 1=Spiral Melt, 2=Zoom Melt, 3=Gravity Dripping.
- `edgeAmt` (0..2, def 0.0): Melt drift distance / dispersion travel.
- `edgeHold` / `edgeCreep` (0..1.5, def 0.6/0.35): Feedback retention and crawl speed.
- `edgeChroma` (0..1, def 0.5): Red-cyan differential dispersion.

---

## 8. BENDR Dirty
**Type**: Filter | **Service**: `BENDRDirtyService` | **Kernel**: `bendrDirty`
Hardware video desk failure, crossbar switching dropouts, timebase knock, and transient noise.

### Parameters:
- `mixDirt` (0..1, def 0.0): Master failure intensity.
- `mixDirtRate` (0..1, def 0.3): Frequency of glitch events.
- `mixDirtKnock` (0..1, def 0.5): Timebase knock horizontal shearing.
- `mixDirtDrop` / `mixDirtCut` (0..1, def 0.5/0.4): Scanline dropout bands and digital cutouts.

---

## 9. BENDR Flow
**Type**: Filter | **Service**: `BENDRFlowService` | **Kernel**: `bendrFlow`
Optical flow vector field advection, datamosh P-frame hold, and curl noise turbulence.

### Parameters:
- `flowField` (0..4, def 0.0): Vector field mode (Motion, Contour, Curl Noise, Spiral, Turbulence).
- `mosh` / `moshVec` (0..1, def 0.0): P-frame vector hold and shove strength.
- `flowGain` / `flowCurl` (0..3/-1..1, def 1.0/0.0): Flow displacement amplitude and vorticity.
- `moshBlock` / `moshBlockSize` (0..1, def 0.0/0.68): Macroblock motion vector trash.

---

## 10. BENDR Signal Lab
**Type**: Filter | **Service**: `BENDRSignalLabService` | **Kernel**: `bendrSignalLab`
Experimental video signal modulation: 1-bit Bayer dither, FM carrier modulation, slitscan, and PNG avalanche.

### Parameters:
- `bitCrush` / `bitScale` (0..1, def 0.0/0.4): 1-Bit 4×4 Bayer matrix ordered dither crush.
- `fmAmt` / `fmCarrier` (0..1, def 0.0/0.35): Frequency modulation carrier synthesis.
- `slitscan` / `slitDir` (0..1, def 0.0): Time-domain raster slit scanning.
- `pngAmt` / `pngRun` (0..1, def 0.0/0.4): Lossless PNG predictive filter corruption avalanche.

---

## 11. BENDR Synth
**Type**: Generator / Filter | **Service**: `BENDRSynthService` | **Kernel**: `bendrSynth`
Pure analog video synthesizer oscillator generating geometric waveforms and HSV spectrum bands.

### Parameters:
- `shape` (0..5, def 0.0): 0=Raster Lines, 1=Radial Rings, 2=Spiral, 3=Lissajous, 4=Checker Grid, 5=Starburst.
- `wave` (0..4, def 0.0): Sine, Triangle, Sawtooth, Square, Noise.
- `genFold` / `genFoldN` (0..1/1..16, def 0.0/4.0): Wavefolding symmetry and folding count.
- `genFM` (0..1, def 0.0): Quadrature cross-frequency modulation.
- `genHue` / `genSpread` / `genBands` (0..1/0..2/2..16): HSV harmonic rainbow spectrum mapper.

---

## 12. BENDR Transition
**Type**: Transition / Filter | **Service**: `BENDRTransitionService` | **Kernel**: `bendrTransition`
Circuit-bent broadcast mixer transitions: 12 geometric wipes, slides, stretches, keyers, and 24 blend modes.

### Parameters:
- `abMix` (0..1, def 0.0): Transition progress fader between Source A and Source B.
- `mixMode` (0..20, def 0.0): 0=Cross Dissolve, 1=H Wipe, 2=V Wipe, 3=Diag Wipe, 4=Box Wipe, 5=Circle Wipe, 6=H Split, 7=V Split, 8=Blinds H, 9=Blinds V, 10=Clock Wipe, 11=Checker Wipe, 12=Noise Wipe, 13-16=Slides, 17-20=Stretches.
- `mixBlend` (0..23, def 0): 24 hardware blend modes (Add, Multiply, Screen, Difference, Grain Extract, etc.).
- `wipeBord` / `wipeBordCol` (0..1, def 0.0): Transition edge border highlight line and color palette.

---

## 13. BENDR Spatial
**Type**: Filter | **Service**: `BENDRSpatialService` | **Kernel**: `bendrSpatial`
Spatial affine transformations, mirroring, multi-grid array tiling, and N-fold kaleidoscope.

### Parameters:
- `srcZoom` / `srcRot` / `srcX` / `srcY` (-1..1, def 0.0): Affine translation, scale, and rotation.
- `multiN` (1..8, def 1.0): Multi-tile video array grid.
- `kaleido` / `kaleidoN` / `kaleidoRot` (0..1/2..12/-1..1, def 0.0/3.0/0.0): N-fold symmetrical kaleidoscope fold.
- `tdAmt` / `tdMap` (0..1/0..4, def 0.0): Luminance/Radial time displacement mapping.

---

## 14. BENDR Optics
**Type**: Filter | **Service**: `BENDROpticsService` | **Kernel**: `bendrOptics`
Lens optical phenomena, anamorphic blue flare streaks, radial chromatic aberration, light leaks, and retro camcorder HUD.

### Parameters:
- `lensStreak` / `streakHue` (0..1, def 0.0/1.0): Anamorphic horizontal flare streak on highlights.
- `lensCA` (0..1, def 0.0): Radial chromatic aberration (red/blue fringing).
- `bloom` / `halation` (0..1, def 0.0): Lens highlight bloom and film red halation.
- `lightLeak` / `leakHue` (0..1, def 0.0/0.05): Warm edge exposure light leak.
- `osdShow` / `osdGlow` (0..1, def 0.0/0.5): Retro camcorder HUD (blinking red REC dot + timecode).
