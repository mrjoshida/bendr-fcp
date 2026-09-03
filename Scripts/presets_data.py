#!/usr/bin/env python3
"""
presets_data.py — Curated preset library for BENDR Final Cut Pro Suite.
Ports circuit-bent looks from BENDR web (p40_presets.js) and plugin signature recipes.
"""

PRESETS = [
    # =========================================================================
    # 1. BENDR VHS
    # =========================================================================
    {
        "name": "Broadcast Decay",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Subtle RF broadcast degradation, dot crawl, ringing, and line wobble",
        "params": {
            "chromaBleed": 0.35, "chromaDelay": 0.12, "rainbow": 0.3, "dotCrawl": 0.3,
            "ringing": 0.35, "signalNoise": 0.12, "chromaNoise": 0.1, "hWobble": 0.1,
            "wobbleFreq": 0.15, "jitter": 0.2, "humBar": 0.25, "tapeWow": 0.1,
            "headSwitch": 0.2, "genLoss": 0.15, "genCount": 2.0
        }
    },
    {
        "name": "Chewed Tape",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Severe tape crease damage, dropout bursts, tracking hunt, and chroma loss",
        "params": {
            "tracking": 0.55, "trackHunt": 0.6, "trackPhase": -0.2, "crease": 0.6,
            "creasePos": 0.44, "dropout": 0.5, "dropoutLen": 0.7, "chromaLoss": 0.4,
            "hiss": 0.3, "genLoss": 0.35, "genCount": 4.0, "headSwitch": 0.45,
            "tapeWow": 0.35, "chromaBleed": 0.45, "signalNoise": 0.12
        }
    },
    {
        "name": "Dead Deck",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Heavily worn deck with head switching noise, dropouts, and generation loss",
        "params": {
            "chromaBleed": 0.6, "chromaDelay": 0.25, "rainbow": 0.15, "dotCrawl": 0.2,
            "signalNoise": 0.3, "chromaNoise": 0.25, "hWobble": 0.2, "jitter": 0.5,
            "tracking": 0.55, "dropout": 0.5, "headSwitch": 0.8, "tapeWow": 0.5,
            "genLoss": 0.55, "genCount": 6.0, "humBar": 0.2
        }
    },
    {
        "name": "Sync Death",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Horizontal sync hook tearing, vertical rolling drift, and line jitter",
        "params": {
            "tear": 0.55, "tearSize": 0.5, "hWobble": 0.45, "wobbleFreq": 0.4,
            "vRoll": 0.12, "jitter": 0.6, "humBar": 0.5, "signalNoise": 0.25,
            "chromaBleed": 0.3, "headSwitch": 0.6
        }
    },
    {
        "name": "Sixth Generation Dub",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Compounded multi-generation dubbing loss with high tape hiss and edge ringing",
        "params": {
            "tapeSpeed": 0.85, "genLoss": 0.55, "genCount": 9.0, "chromaLoss": 0.5,
            "hiss": 0.35, "headSwitch": 0.5, "tapeWow": 0.3, "wowRate": 0.35,
            "chromaBleed": 0.6, "dotCrawl": 0.3, "ringing": 0.2
        }
    },
    {
        "name": "Head Clog",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Severe tape head clogging, azimuth misalignment, and chroma loss",
        "params": {
            "headClog": 0.75, "azimuth": 0.5, "tracking": 0.3, "chromaLoss": 0.6,
            "hiss": 0.3, "dropout": 0.35, "headSwitch": 0.4, "chromaBleed": 0.4
        }
    },
    {
        "name": "Dying Spool",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "Extreme wow and flutter, stretched tape, edge damage, and print-through",
        "params": {
            "tapeStretch": 0.7, "flutter": 0.7, "wowRate": 0.6, "tapeWow": 0.6,
            "edgeDmg": 0.6, "crease": 0.4, "creasePos": 0.7, "printThru": 0.5,
            "hiss": 0.45, "chromaLoss": 0.45, "genLoss": 0.4, "genCount": 5.0,
            "dropout": 0.45, "dropoutLen": 0.8, "chromaBleed": 0.5
        }
    },
    {
        "name": "Pause Still Frame",
        "plugin": "BENDR VHS",
        "category": "BENDR - VHS",
        "desc": "VCR pause mode with helical head still-frame noise and flutter",
        "params": {
            "stillNoise": 0.8, "headSwitch": 0.6, "tapeStretch": 0.3, "flutter": 0.4,
            "tracking": 0.25, "hiss": 0.25, "chromaBleed": 0.35, "signalNoise": 0.1
        }
    },

    # =========================================================================
    # 2. BENDR CRT
    # =========================================================================
    {
        "name": "CRT Rephoto",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "Camera rephotographing CRT glass with bloom flare, halation, and defocus",
        "params": {
            "bloom": 0.5, "bloomRad": 0.35, "halation": 0.5, "defocus": 0.3,
            "grain": 0.45, "scanlines": 0.4, "curvature": 0.4, "vignette": 0.55,
            "outContrast": 1.15, "outSat": 1.1
        }
    },
    {
        "name": "Arcade Slot Mask",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "High-contrast arcade coin-op monitor with slot mask phosphor triad",
        "params": {
            "outModel": 2.0, "scanlines": 0.65, "maskDark": 0.6,
            "curvature": 0.2, "cornerRound": 0.15, "vignette": 0.4,
            "bloom": 0.4, "halation": 0.2
        }
    },
    {
        "name": "Dot Triad Shadow Mask",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "Classic consumer color television delta dot triad screen texture",
        "params": {
            "outModel": 3.0, "scanlines": 0.6, "maskDark": 0.55,
            "curvature": 0.25, "cornerRound": 0.2, "vignette": 0.45,
            "bloom": 0.3, "glassRefl": 0.2
        }
    },
    {
        "name": "BW Security Monitor",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "Monochrome surveillance monitor with persistent phosphor and heavy scanlines",
        "params": {
            "outModel": 4.0, "scanlines": 0.75, "maskDark": 0.4,
            "curvature": 0.3, "cornerRound": 0.25, "vignette": 0.5,
            "outContrast": 1.3, "outBright": 0.05, "phosphor": 0.3
        }
    },
    {
        "name": "Worn Tube Overdrive",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "Aged CRT display with intense electron beam scatter and warm halation",
        "params": {
            "outModel": 1.0, "scanlines": 0.4, "bloom": 0.7,
            "bloomRad": 0.6, "halation": 0.6, "vignette": 0.5,
            "outWarmth": 0.2
        }
    },
    {
        "name": "Studio Trinitron",
        "plugin": "BENDR CRT",
        "category": "BENDR - CRT",
        "desc": "Precision broadcast production monitor with fine aperture grille",
        "params": {
            "outModel": 1.0, "scanlines": 0.5, "maskDark": 0.45,
            "curvature": 0.08, "cornerRound": 0.05, "vignette": 0.25,
            "bloom": 0.25, "bloomRad": 0.3
        }
    },

    # =========================================================================
    # 3. BENDR Feedback
    # =========================================================================
    {
        "name": "Droste Tunnel",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Infinite optical corridor feedback tunnel with subtle edge diffusion",
        "params": {
            "fbAmount": 0.9, "fbZoom": 0.2, "fbRotate": 0.0,
            "fbBlur": 0.06, "fbNoise": 0.05, "fbWrap": 1.0, "fbNL": 1.0
        }
    },
    {
        "name": "Rainbow Tunnel",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Recursive feedback loop with rotating spectral HSV hue dispersion",
        "params": {
            "fbAmount": 0.92, "fbZoom": 0.2, "fbHue": 0.05,
            "fbSat": 1.02, "fbBlur": 0.06, "fbNoise": 0.05,
            "fbWrap": 1.0, "fbNL": 1.0
        }
    },
    {
        "name": "Slow Vortex",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Gentle vortex swirling feedback with chromatic trail drift",
        "params": {
            "fbAmount": 0.94, "fbZoom": 0.05, "fbRotate": 0.07,
            "fbHue": 0.02, "fbBlur": 0.09, "fbNoise": 0.05,
            "fbWrap": 1.0, "fbNL": 1.0
        }
    },
    {
        "name": "9-Fold Mandala",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Resonant rotational feedback locked into a 9-arm mandala structure",
        "params": {
            "fbAmount": 0.94, "fbZoom": 0.017, "fbRotate": 0.7,
            "fbBlur": 0.07, "fbSharp": 0.3, "fbNoise": 0.04,
            "fbWrap": 1.0, "fbNL": 1.0
        }
    },
    {
        "name": "Howl-Around",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Dr. Who title sequence howling video amplifier overdrive loop",
        "params": {
            "fbAmount": 0.99, "fbZoom": -0.033, "fbRotate": -0.05,
            "fbShiftX": 0.017, "fbShiftY": -0.033, "fbSharp": 1.0,
            "fbDrive": 3.0, "fbNoise": 0.6, "fbBlur": 0.04, "fbNL": 0.0
        }
    },
    {
        "name": "Comet Trails",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Luminescent light streaks with directional horizontal shear",
        "params": {
            "fbAmount": 0.9, "fbShiftX": 0.066, "fbNoise": 0.03,
            "fbNL": 0.0, "fbBlend": 3.0
        }
    },
    {
        "name": "Turing Labyrinth",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Reaction-diffusion pattern formation using Difference-of-Gaussians filtering",
        "params": {
            "fbAmount": 0.97, "fbBlur": 0.13, "fbBlur2": 0.4,
            "fbSharp": 1.1, "fbThresh": 0.5, "fbThreshSoft": 0.05,
            "fbNoise": 0.5, "fbAuto": 0.6, "fbNL": 0.0
        }
    },
    {
        "name": "Cellular Automata",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Organic living cellular feedback structures created by threshold folding",
        "params": {
            "fbAmount": 0.96, "fbZoom": -0.007, "fbBlur": 0.22,
            "fbSharp": 1.2, "fbThresh": 0.48, "fbThreshSoft": 0.02,
            "fbNoise": 0.45, "fbAuto": 0.8, "fbWrap": 1.0, "fbNL": 0.0
        }
    },
    {
        "name": "Fire Column",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "Upward thermal convection feedback smear with warm fiery gain",
        "params": {
            "fbAmount": 0.95, "fbZoom": -0.04, "fbShiftY": -0.04,
            "fbHue": -0.03, "fbBlur": 0.11, "fbDrive": 1.5,
            "fbGainR": 1.15, "fbGainB": 0.8, "fbNoise": 0.25,
            "fbWrap": 1.0, "fbNL": 1.0
        }
    },
    {
        "name": "Crystalline Rosette",
        "plugin": "BENDR Feedback",
        "category": "BENDR - Feedback",
        "desc": "High-frequency resonant geometric rosette feedback crystal",
        "params": {
            "fbAmount": 0.94, "fbZoom": 0.033, "fbRotate": 0.26,
            "fbBlur": 0.01, "fbSharp": 1.5, "fbNoise": 0.05,
            "fbWrap": 1.0, "fbNL": 0.0
        }
    },

    # =========================================================================
    # 4. BENDR Colour
    # =========================================================================
    {
        "name": "Rainbow Rite",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Sweeping isoline color bands, high saturation, and enhancer glow",
        "params": {
            "colorize": 0.85, "colorBands": 1.8, "colorSweep": 0.25,
            "saturation": 1.3, "glow": 0.45, "contrast": 1.15
        }
    },
    {
        "name": "Psych Wash",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Luma-to-chroma cross-synthesis, RGB channel split, and posterization",
        "params": {
            "lumaHue": 0.65, "rgbSep": 0.35, "invFlick": 0.28,
            "saturation": 2.1, "posterize": 0.3, "glow": 0.5, "contrast": 1.3
        }
    },
    {
        "name": "Enhancer Burn",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Peaking differentiator overshoot, solarization, and edge ringing",
        "params": {
            "rgbSep": 0.22, "contrast": 1.55,
            "saturation": 1.6, "glow": 0.7, "solarize": 0.2
        }
    },
    {
        "name": "Neon Haze",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Luma-keyed neon glow, chromatic separation, and warm color wash",
        "params": {
            "lumaHue": 0.3, "rgbSep": 0.15, "colorize": 0.3,
            "colorBands": 1.2, "saturation": 2.0, "hue": 0.08,
            "posterize": 0.35, "solarize": 0.25, "glow": 0.65
        }
    },
    {
        "name": "Vol I — Enhancer Lines",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Fine contour isolines, luma quantizer steps, and crisp edge relief",
        "params": {
            "contour": 0.95, "contourBands": 9.0, "contourWidth": 1.3,
            "contourHue": 0.04, "contourFill": 0.18, "lumaSteps": 0.55,
            "stepCount": 5.0, "contrast": 1.25, "saturation": 0.55,
            "glow": 0.08
        }
    },
    {
        "name": "Vol II — Colouriser",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Bold psychedelic color banded contours and harmonic wash",
        "params": {
            "contour": 0.45, "contourBands": 9.0, "contourWidth": 1.6,
            "contourHue": 0.5, "contourFill": 0.7, "lumaSteps": 0.75,
            "stepCount": 5.0, "colorize": 0.6, "colorBands": 1.6,
            "colorSweep": 0.18, "saturation": 1.7, "lumaHue": 0.25,
            "glow": 0.45, "contrast": 1.25
        }
    },
    {
        "name": "Vol III — Full Bend",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "High-density contour isolines, 1-bit dither, and heavy RGB split",
        "params": {
            "contour": 0.6, "contourBands": 12.0, "contourWidth": 1.0,
            "contourHue": 0.35, "contourFill": 0.35, "lumaSteps": 0.6,
            "stepCount": 7.0, "dither": 0.4, "colorize": 0.5,
            "colorBands": 2.4, "lumaHue": 0.4, "rgbSep": 0.2,
            "saturation": 1.8, "contrast": 1.35, "glow": 0.5
        }
    },
    {
        "name": "Lines — Engraving",
        "plugin": "BENDR Colour",
        "category": "BENDR - Colour",
        "desc": "Serpentine analog line-delay feedback buffer simulation",
        "params": {
            "mline": 1.0, "mlineGain": 1.2, "mlineScale": 1.0,
            "mlineFb": 0.95, "mlineWin": 40.0, "mlineTint": 0.0,
            "mlineSerp": 1.0, "contrast": 1.25, "saturation": 0.4
        }
    },

    # =========================================================================
    # 5. BENDR Scan
    # =========================================================================
    {
        "name": "Rutt-Etra Raster",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "Classic 1970s Rutt-Etra cathode-ray video deflection synthesizer",
        "params": {
            "scanLines": 120.0, "scanSamples": 256.0, "scanAmt": 0.65,
            "scanWidth": 0.35, "scanVel": 0.8, "scanTiltX": 0.15,
            "scanTiltY": 0.25, "scanPersp": 0.4, "scanCurve": 0.2
        }
    },
    {
        "name": "Oscilloscope Wobble",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "High-amplitude sine/LFO beam deflection with Lissajous harmonic modulation",
        "params": {
            "scanLines": 80.0, "scanSamples": 200.0, "scanAmt": 0.8,
            "scanVel": 1.2, "scanWobAmt": 0.5, "scanWobFreq": 0.6,
            "scanLissa": 0.3
        }
    },
    {
        "name": "Paik-Abe Synthesis",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "Nam June Paik & Shuya Abe style video synthesizer 3D deflection raster",
        "params": {
            "scanLines": 160.0, "scanSamples": 320.0, "scanAmt": 0.9,
            "scanPersp": 0.6, "scanTiltX": 0.3, "scanTiltY": -0.2,
            "scanSkew": 0.25, "scanLissa": 0.4, "scanGain": 1.5
        }
    },
    {
        "name": "Topographic Terrain",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "S-curve isometric depth scan mesh creating topographic relief landscape",
        "params": {
            "scanLines": 180.0, "scanSamples": 360.0, "scanAmt": 0.5,
            "scanTiltX": 0.45, "scanTiltY": 0.1, "scanPersp": 0.7,
            "scanCurve": 0.35, "scanGain": 1.1
        }
    },
    {
        "name": "Lissajous Beam Crash",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "Deflection coil collapse generating intersecting Lissajous figures",
        "params": {
            "scanLines": 60.0, "scanSamples": 150.0, "scanAmt": 1.2,
            "scanWobAmt": 0.8, "scanWobFreq": 0.3, "scanLissa": 0.8,
            "scanGain": 1.8
        }
    },
    {
        "name": "Vertical Slit Deflection",
        "plugin": "BENDR Scan",
        "category": "BENDR - Scan",
        "desc": "High line count vertical deflection raster with velocity modulation",
        "params": {
            "scanLines": 240.0, "scanSamples": 200.0, "scanAmt": 0.7,
            "scanVel": 1.4, "scanPersp": 0.5, "scanTiltX": -0.2,
            "scanGain": 1.3
        }
    },

    # =========================================================================
    # 6. BENDR Corrupt
    # =========================================================================
    {
        "name": "Datamosh Macroblocks",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "Macroblock displacement and drift warping simulating dropped P-frames",
        "params": {
            "blockShift": 0.75, "blockSize": 0.45, "fmWarp": 0.45,
            "driftWarp": 0.35, "pixelSort": 0.3, "sortThresh": 0.55
        }
    },
    {
        "name": "Pixel Sort Cascade",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "Directional luminance threshold scanline pixel sorting cascade",
        "params": {
            "pixelSort": 0.9, "sortThresh": 0.42, "driftWarp": 0.12
        }
    },
    {
        "name": "Halftone Dot Matrix",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "High-contrast screen-printing halftone dot matrix rasterization",
        "params": {
            "dotify": 0.92, "dotSize": 0.45
        }
    },
    {
        "name": "DCT Quantization Crush",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "8x8 Discrete Cosine Transform high-frequency block quantizer crushing",
        "params": {
            "dctAmt": 0.85, "dctQ": 0.7, "dctTilt": 0.4,
            "dctChroma": 0.8, "dctBlock": 0.5
        }
    },
    {
        "name": "JPEGs Compression Decay",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "Aggressive JPEG recompression decay with macroblock shifting",
        "params": {
            "blockShift": 0.55, "blockSize": 0.4, "dctAmt": 0.9,
            "dctQ": 0.85, "pixelSort": 0.25, "sortThresh": 0.55
        }
    },
    {
        "name": "FM Warp Drift",
        "plugin": "BENDR Corrupt",
        "category": "BENDR - Corrupt",
        "desc": "High-frequency FM coordinate modulation and horizontal shearing",
        "params": {
            "fmWarp": 0.7, "driftWarp": 0.5, "blockShift": 0.3,
            "blockSize": 0.25
        }
    },

    # =========================================================================
    # 7. BENDR Melt
    # =========================================================================
    {
        "name": "Liquid Melt",
        "plugin": "BENDR Melt",
        "category": "BENDR - Melt",
        "desc": "Viscous fluid smear and chromatic dispersion along detected edges",
        "params": {
            "meltMode": 0.0, "edgeAmt": 1.2, "edgeHold": 0.85,
            "edgeCreep": 0.6, "edgeSwirl": 0.5, "edgeChroma": 0.7,
            "meltHue": 0.1
        }
    },
    {
        "name": "Gravity Drip",
        "plugin": "BENDR Melt",
        "category": "BENDR - Melt",
        "desc": "Downward liquid dripping and trailing edge creep",
        "params": {
            "meltMode": 3.0, "edgeAmt": 1.6, "edgeHold": 0.92,
            "edgeWidth": 0.4, "edgeCreep": 0.8, "edgeChroma": 0.85,
            "meltHue": 0.15
        }
    },
    {
        "name": "Wet Paint Smear",
        "plugin": "BENDR Melt",
        "category": "BENDR - Melt",
        "desc": "Soft lateral paint dispersion with color bleeding",
        "params": {
            "meltMode": 0.0, "edgeAmt": 1.8, "edgeHold": 0.86,
            "edgeWidth": 0.15, "edgeSwirl": 0.0, "meltSoft": 0.55,
            "edgeChroma": 0.65, "meltHue": -0.2
        }
    },
    {
        "name": "Spiral Melt Vortex",
        "plugin": "BENDR Melt",
        "category": "BENDR - Melt",
        "desc": "Centrifugal rotational fluid advection and chromatic swirling",
        "params": {
            "meltMode": 1.0, "edgeAmt": 1.4, "edgeHold": 0.9,
            "edgeSwirl": 0.6, "edgeCreep": 0.5, "edgeChroma": 0.6,
            "meltZoom": 0.3
        }
    },
    {
        "name": "Zoom Bleed Smear",
        "plugin": "BENDR Melt",
        "category": "BENDR - Melt",
        "desc": "Radial zoom expansion and highlight color smear",
        "params": {
            "meltMode": 2.0, "edgeAmt": 1.5, "edgeHold": 0.88,
            "meltZoom": 0.7, "edgeSwirl": 0.2, "edgeChroma": 0.75,
            "meltHue": 0.2
        }
    },

    # =========================================================================
    # 8. BENDR Dirty
    # =========================================================================
    {
        "name": "Crossbar Glitch Fault",
        "plugin": "BENDR Dirty",
        "category": "BENDR - Dirty",
        "desc": "Intermittent video switcher crossbar routing faults and dropouts",
        "params": {
            "mixDirt": 0.85, "mixDirtRate": 0.7, "mixDirtKnock": 0.6,
            "mixDirtDrop": 0.65, "mixDirtCut": 0.35, "mixDirtNoise": 0.4
        }
    },
    {
        "name": "Timebase Knock Jitter",
        "plugin": "BENDR Dirty",
        "category": "BENDR - Dirty",
        "desc": "Timebase corrector synchronization knock and horizontal line shear",
        "params": {
            "mixDirt": 0.9, "mixDirtRate": 0.9, "mixDirtKnock": 0.95,
            "mixDirtDrop": 0.3, "mixDirtCut": 0.1, "mixDirtNoise": 0.2
        }
    },
    {
        "name": "Dropout Storm",
        "plugin": "BENDR Dirty",
        "category": "BENDR - Dirty",
        "desc": "Dense scanline dropout bands and digital switching flashes",
        "params": {
            "mixDirt": 0.95, "mixDirtRate": 0.8, "mixDirtKnock": 0.4,
            "mixDirtDrop": 0.9, "mixDirtCut": 0.7, "mixDirtNoise": 0.6
        }
    },
    {
        "name": "Desk Power Sag",
        "plugin": "BENDR Dirty",
        "category": "BENDR - Dirty",
        "desc": "Analog video console power rail sag, noise bursts, and sync flicker",
        "params": {
            "mixDirt": 0.7, "mixDirtRate": 0.4, "mixDirtKnock": 0.5,
            "mixDirtDrop": 0.5, "mixDirtCut": 0.6, "mixDirtNoise": 0.7
        }
    },

    # =========================================================================
    # 9. BENDR Flow
    # =========================================================================
    {
        "name": "Optical Flow Curl Noise",
        "plugin": "BENDR Flow",
        "category": "BENDR - Flow",
        "desc": "Multi-scale curl noise turbulent advection vector field",
        "params": {
            "flowField": 2.0, "moshVec": 0.85, "flowGain": 1.8,
            "flowCurl": 0.7, "flowEdge": 1.0, "mosh": 0.3
        }
    },
    {
        "name": "Datamosh P-Frame Drag",
        "plugin": "BENDR Flow",
        "category": "BENDR - Flow",
        "desc": "Aggressive P-frame motion vector hold and directional shove",
        "params": {
            "flowField": 0.0, "mosh": 0.93, "moshVec": 0.85,
            "flowGain": 1.4, "flowSharp": 0.2
        }
    },
    {
        "name": "Contour Vector Crawl",
        "plugin": "BENDR Flow",
        "category": "BENDR - Flow",
        "desc": "Flow vector field guided along high-contrast object contours",
        "params": {
            "flowField": 1.0, "mosh": 0.9, "moshVec": 0.7,
            "flowCurl": 0.35, "flowGain": 1.6, "flowSharp": 0.3
        }
    },
    {
        "name": "Turbulence Swirl Vortex",
        "plugin": "BENDR Flow",
        "category": "BENDR - Flow",
        "desc": "Rotational fluid vortices with dynamic chromatic advection",
        "params": {
            "flowField": 4.0, "swirl": 0.8, "swirlScale": 0.4,
            "swirlSpeed": 0.3, "flowGain": 1.5, "flowHue": 0.3
        }
    },
    {
        "name": "Vector Trash Block Mosh",
        "plugin": "BENDR Flow",
        "category": "BENDR - Flow",
        "desc": "Corrupted macroblock vector trash and motion block displacement",
        "params": {
            "flowField": 0.0, "moshBlock": 0.8, "moshBlockSize": 0.85,
            "moshRate": 0.42, "mosh": 0.6
        }
    },

    # =========================================================================
    # 10. BENDR Signal Lab
    # =========================================================================
    {
        "name": "1-Bit Bayer Dither Crush",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "Vintage 4x4 Bayer matrix ordered dither with monochrome crushing",
        "params": {
            "bitCrush": 0.9, "bitScale": 0.4
        }
    },
    {
        "name": "FM Carrier Modulation",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "RF carrier frequency modulation synthesis on video scanlines",
        "params": {
            "fmAmt": 0.85, "fmCarrier": 0.4
        }
    },
    {
        "name": "Slitscan Time Warp",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "Continuous time-domain raster slit scanning displacement",
        "params": {
            "slitscan": 0.8, "slitDir": 0.0
        }
    },
    {
        "name": "PNG Avalanche Glitch",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "Lossless PNG predictive filter reconstruction error avalanche",
        "params": {
            "pngAmt": 0.85, "pngDir": 0.0, "pngRun": 0.6
        }
    },
    {
        "name": "NTSC Crosstalk Fringing",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "3.58 MHz color subcarrier crosstalk and high-frequency fringing",
        "params": {
            "ntscArt": 0.9, "ntscFringe": 0.7, "snow": 0.3, "snowAniso": 0.5
        }
    },
    {
        "name": "Radial Field Warp",
        "plugin": "BENDR Signal Lab",
        "category": "BENDR - Signal Lab",
        "desc": "Polar coordinate field synthesis with color phase modulation",
        "params": {
            "fieldMod": 0.8, "fieldSrc": 2.0, "fieldWarp": 0.6, "fieldHue": 0.4
        }
    },

    # =========================================================================
    # 11. BENDR Synth
    # =========================================================================
    {
        "name": "Starburst FM",
        "plugin": "BENDR Synth",
        "category": "BENDR - Synth",
        "desc": "8-point wavefolded starburst oscillator with quadrature cross-FM",
        "params": {
            "shape": 6.0, "wave": 0.0, "colmode": 2.0, "genFreqX": 0.2,
            "genFreqY": 0.2, "genFM": 0.45, "genFold": 0.6, "genFoldN": 8.0,
            "genHue": 0.55, "genSpread": 1.2, "genSat": 0.95, "genBright": 1.1,
            "genBands": 8.0
        }
    },
    {
        "name": "Spiral Drive",
        "plugin": "BENDR Synth",
        "category": "BENDR - Synth",
        "desc": "Rotating wavefolded spiral oscillator with harmonic spectrum mapper",
        "params": {
            "shape": 2.0, "wave": 1.0, "colmode": 2.0, "genFreqX": 0.3,
            "genFoldN": 6.0, "genRate": 0.12, "genSpread": 1.5,
            "genHue": 0.1, "genSat": 1.0, "genFold": 0.25
        }
    },
    {
        "name": "Hard Geometric Shapes",
        "plugin": "BENDR Synth",
        "category": "BENDR - Synth",
        "desc": "Analog comparator threshold square wave kaleidoscope pattern",
        "params": {
            "shape": 7.0, "wave": 3.0, "colmode": 3.0, "genFreqX": 0.22,
            "genFoldN": 8.0, "genComp": 1.0, "genThresh": 0.5,
            "genSoft": 0.02, "genSpread": 0.7, "genHue": 0.85, "genSat": 1.0
        }
    },
    {
        "name": "Plasma Rainbow Bands",
        "plugin": "BENDR Synth",
        "category": "BENDR - Synth",
        "desc": "Cross-modulated Lissajous plasma with rainbow harmonic spectrum",
        "params": {
            "shape": 3.0, "wave": 0.0, "colmode": 4.0, "genFreqX": 0.2,
            "genFreqY": 0.16, "genFM": 0.55, "genBands": 9.0,
            "genSpread": 1.6, "genHue": 0.3, "genSat": 0.95, "genRate": 0.14
        }
    },
    {
        "name": "Folded Radial Rings",
        "plugin": "BENDR Synth",
        "category": "BENDR - Synth",
        "desc": "High-symmetry concentric wavefolded rings with domain warping",
        "params": {
            "shape": 1.0, "wave": 0.0, "colmode": 1.0, "genFreqX": 0.3,
            "genFold": 0.6, "genWarp": 0.45, "genSpread": 1.3,
            "genHue": 0.62, "genSat": 0.9, "genRate": 0.09
        }
    },

    # =========================================================================
    # 12. BENDR Transition
    # =========================================================================
    {
        "name": "Clock Wipe Highlight",
        "plugin": "BENDR Transition",
        "category": "BENDR - Transitions",
        "desc": "Radial clock wipe with magenta neon edge highlight line",
        "params": {
            "abMix": 0.5, "mixMode": 10.0, "wipeBord": 0.75,
            "wipeBordCol": 0.5, "wipeSoft": 0.03
        }
    },
    {
        "name": "Checkerboard Dissolve",
        "plugin": "BENDR Transition",
        "category": "BENDR - Transitions",
        "desc": "Multi-block alternating checkerboard matrix transition",
        "params": {
            "abMix": 0.5, "mixMode": 11.0, "wipeRep": 4.0, "wipeSoft": 0.05
        }
    },
    {
        "name": "Noise Scatter Wipe",
        "plugin": "BENDR Transition",
        "category": "BENDR - Transitions",
        "desc": "High-frequency random noise scatter wipe dissolve",
        "params": {
            "abMix": 0.5, "mixMode": 12.0, "wipeSoft": 0.2, "wipeDetail": 0.6
        }
    },
    {
        "name": "Luma Keyer Burn In",
        "plugin": "BENDR Transition",
        "category": "BENDR - Transitions",
        "desc": "Highlight luminance threshold key transition with soft border",
        "params": {
            "abMix": 0.5, "mixMode": 0.0, "mixKey": 1.0,
            "mixKeyThresh": 0.5, "mixKeySoft": 0.2, "mixKeyHue": 0.33
        }
    },
    {
        "name": "Slide Push Edge Line",
        "plugin": "BENDR Transition",
        "category": "BENDR - Transitions",
        "desc": "Directional slide push with highlighted seam border",
        "params": {
            "abMix": 0.5, "mixMode": 13.0, "wipeBord": 0.8, "wipeBordCol": 0.2
        }
    },

    # =========================================================================
    # 13. BENDR Spatial
    # =========================================================================
    {
        "name": "80s Triangle Kaleidoscope",
        "plugin": "BENDR Spatial",
        "category": "BENDR - Spatial",
        "desc": "3-fold triangular kaleidoscopic mirror symmetry fold",
        "params": {
            "kaleido": 1.0, "kaleidoN": 3.0, "kaleidoRot": 0.15, "srcZoom": 0.15
        }
    },
    {
        "name": "Blade Runner Hexagon Fold",
        "plugin": "BENDR Spatial",
        "category": "BENDR - Spatial",
        "desc": "6-fold radial kaleidoscope with rotation and zoom",
        "params": {
            "kaleido": 1.0, "kaleidoN": 6.0, "kaleidoRot": -0.1, "srcZoom": 0.2
        }
    },
    {
        "name": "4x4 Video Wall Grid",
        "plugin": "BENDR Spatial",
        "category": "BENDR - Spatial",
        "desc": "Multi-screen 16-tile array matrix video wall",
        "params": {
            "multiN": 4.0, "srcZoom": 0.0
        }
    },
    {
        "name": "Time Displacement Warp",
        "plugin": "BENDR Spatial",
        "category": "BENDR - Spatial",
        "desc": "Luminance-driven temporal mapping and displacement warp",
        "params": {
            "tdAmt": 0.7, "tdMap": 2.0, "tdSpread": 0.8,
            "tdSoft": 1.0, "tdWarp": 0.3
        }
    },
    {
        "name": "Camera Shake and Drift",
        "plugin": "BENDR Spatial",
        "category": "BENDR - Spatial",
        "desc": "Dynamic handheld camera jitter, shake, and rotation drift",
        "params": {
            "shake": 0.6, "shakeRate": 1.5, "srcZoom": 0.1
        }
    },

    # =========================================================================
    # 14. BENDR Optics
    # =========================================================================
    {
        "name": "Retro Camcorder HUD",
        "plugin": "BENDR Optics",
        "category": "BENDR - Optics",
        "desc": "Authentic VHS camcorder OSD (REC dot + battery + timecode) and lens flare",
        "params": {
            "osdShow": 1.0, "osdGlow": 0.7, "lensCA": 0.4,
            "vignette": 0.4, "grain": 0.2
        }
    },
    {
        "name": "Anamorphic Blue Streak and Bloom",
        "plugin": "BENDR Optics",
        "category": "BENDR - Optics",
        "desc": "Horizontal anamorphic flare streak on highlights with optical bloom",
        "params": {
            "lensStreak": 0.85, "streakHue": 0.6, "bloom": 0.65,
            "bloomRad": 0.35, "halation": 0.5, "vignette": 0.4
        }
    },
    {
        "name": "Vintage Film Halation and Grain",
        "plugin": "BENDR Optics",
        "category": "BENDR - Optics",
        "desc": "Warm red film halation, heavy stock grain, scratches, and light leaks",
        "params": {
            "halation": 0.85, "bloom": 0.4, "grain": 0.4,
            "lightLeak": 0.4, "leakHue": 0.08, "dust": 0.3, "scratches": 0.35
        }
    },
    {
        "name": "Dirty Glass and Flare",
        "plugin": "BENDR Optics",
        "category": "BENDR - Optics",
        "desc": "Smudged front lens element, warm edge light leak, and vignette",
        "params": {
            "lensSmudge": 0.7, "lightLeak": 0.6, "leakHue": 0.05,
            "bloom": 0.5, "vignette": 0.45
        }
    },
    {
        "name": "Heavy Chromatic Aberration",
        "plugin": "BENDR Optics",
        "category": "BENDR - Optics",
        "desc": "Extreme radial red-cyan optical dispersion and edge fringing",
        "params": {
            "lensCA": 0.9, "lensStreak": 0.3, "vignette": 0.5, "grain": 0.15
        }
    }
]
