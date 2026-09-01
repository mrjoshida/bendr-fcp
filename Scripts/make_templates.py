#!/usr/bin/env python3
"""
make_templates.py — Generates Final Cut Pro Motion Templates for all 14 BENDR plugins.
Installs templates directly to ~/Movies/Motion Templates.localized/Effects.localized/BENDR/
and ~/Movies/Motion Templates.localized/Transitions.localized/BENDR/
"""

import os
import sys
import plistlib
from pathlib import Path

# Template metadata for all 14 plugins
PLUGINS = [
    # Phase 1
    {"name": "BENDR VHS", "uuid": "B4C2D1E0-4567-4890-ABCD-EF0123456780", "type": "effect", "desc": "VHS tape degradation & NTSC artifacts"},
    {"name": "BENDR CRT", "uuid": "B4C2D1E0-4567-4890-ABCD-EF0123456781", "type": "effect", "desc": "CRT monitor scanlines, shadow mask & phosphor"},
    {"name": "BENDR Feedback", "uuid": "B4C2D1E0-4567-4890-ABCD-EF0123456782", "type": "effect", "desc": "Recursive video feedback tunnels"},
    # Phase 2
    {"name": "BENDR Colour", "uuid": "C1A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A78", "type": "effect", "desc": "Video-mixer color, enhancer & differentiators"},
    {"name": "BENDR Scan", "uuid": "C2A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A79", "type": "effect", "desc": "Cathode-ray deflection & 3D raster geometry"},
    {"name": "BENDR Corrupt", "uuid": "C3A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A7A", "type": "effect", "desc": "Pixel sorting, DCT blocks & halftone"},
    # Phase 3
    {"name": "BENDR Melt", "uuid": "F1A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A70", "type": "effect", "desc": "Organic feedback smear & edge melt"},
    {"name": "BENDR Dirty", "uuid": "F2A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A71", "type": "effect", "desc": "Hardware desk failure, knock & dropouts"},
    {"name": "BENDR Flow", "uuid": "F3A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A72", "type": "effect", "desc": "Optical flow advection & datamosh vector fields"},
    {"name": "BENDR Signal Lab", "uuid": "F4A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A73", "type": "effect", "desc": "Circuit-bent glitch & signal synthesis lab"},
    # Phase 4
    {"name": "BENDR Synth", "uuid": "F5A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A74", "type": "effect", "desc": "Video synthesizer & pattern generator"},
    {"name": "BENDR Transition", "uuid": "F6A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A75", "type": "transition", "desc": "Video-mixer wipes, slide & keyer transition"},
    {"name": "BENDR Spatial", "uuid": "F7A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A76", "type": "effect", "desc": "Framing, multi-grid, kaleido & time displace"},
    {"name": "BENDR Optics", "uuid": "F8A2B3C4-D5E6-4789-8A1B-2C3D4E5F6A77", "type": "effect", "desc": "Lens aberration, halation, bloom & camcorder HUD"},
]

def generate_moef_xml(plugin_name, plugin_uuid):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ozxmlscene>
<ozscene version="5.13">
    <factory id="1" uuid="{plugin_uuid}" name="{plugin_name}">
        <description>BENDR Circuit-Bent Video Processing Plugin</description>
    </factory>
    <build>
        <version>5.6</version>
    </build>
    <scene>
        <sceneSettings>
            <width>1920</width>
            <height>1080</height>
            <duration>300</duration>
            <frameRate>30</frameRate>
            <pixelAspectRatio>1</pixelAspectRatio>
            <fieldOrder>0</fieldOrder>
            <colorDepth>2</colorDepth>
        </sceneSettings>
        <displaySettings>
            <renderPreset>1</renderPreset>
        </displaySettings>
        <timelineProperties>
            <inPoint>0</inPoint>
            <outPoint>300</outPoint>
        </timelineProperties>
        <layers>
            <layer id="1000" name="Effect Source">
                <effects>
                    <filter id="1001" name="{plugin_name}" factoryID="1"/>
                </effects>
            </layer>
        </layers>
    </scene>
</ozscene>
"""

def generate_motr_xml(plugin_name, plugin_uuid):
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ozxmlscene>
<ozscene version="5.13">
    <factory id="1" uuid="{plugin_uuid}" name="{plugin_name}">
        <description>BENDR Circuit-Bent Transition</description>
    </factory>
    <build>
        <version>5.6</version>
    </build>
    <scene>
        <sceneSettings>
            <width>1920</width>
            <height>1080</height>
            <duration>30</duration>
            <frameRate>30</frameRate>
            <pixelAspectRatio>1</pixelAspectRatio>
            <fieldOrder>0</fieldOrder>
            <colorDepth>2</colorDepth>
        </sceneSettings>
        <layers>
            <transition id="2000" name="{plugin_name}" factoryID="1"/>
        </layers>
    </scene>
</ozscene>
"""

def main():
    print("==================================================")
    print("🎬 Generating Final Cut Pro Motion Templates (BENDR)")
    print("==================================================")

    home = Path.home()
    motion_templates_root = home / "Movies" / "Motion Templates.localized"
    effects_dir = motion_templates_root / "Effects.localized" / "BENDR"
    transitions_dir = motion_templates_root / "Transitions.localized" / "BENDR"

    effects_dir.mkdir(parents=True, exist_ok=True)
    transitions_dir.mkdir(parents=True, exist_ok=True)

    # Touch .localized files if not existing
    for loc in [motion_templates_root, motion_templates_root / "Effects.localized", motion_templates_root / "Transitions.localized"]:
        loc_file = loc / ".localized"
        if not loc_file.exists():
            try:
                loc_file.touch()
            except Exception:
                pass

    installed_count = 0

    for p in PLUGINS:
        name = p["name"]
        uuid = p["uuid"]
        ptype = p["type"]
        safe_name = name.replace(" ", "")

        if ptype == "transition":
            bundle_dir = transitions_dir / f"{name}"
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.motr"
            content = generate_motr_xml(name, uuid)
        else:
            bundle_dir = effects_dir / f"{name}"
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.moef"
            content = generate_moef_xml(name, uuid)

        with open(template_file, "w", encoding="utf-8") as f:
            f.write(content)

        print(f"  ✅ Installed: {String(p['name']) if 'String' in globals() else name} -> {bundle_dir.relative_to(home)}")
        installed_count += 1

    print("==================================================")
    print(f"🎉 Successfully generated and installed {installed_count} templates!")
    print("Restart Final Cut Pro to see the BENDR category under Effects and Transitions.")
    print("==================================================")

if __name__ == "__main__":
    main()
