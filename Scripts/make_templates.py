#!/usr/bin/env python3
"""
make_templates.py — Generates Final Cut Pro Motion Templates for all 14 BENDR plugins.
Installs templates directly to ~/Movies/Motion Templates.localized/Effects.localized/BENDR/
and ~/Movies/Motion Templates.localized/Transitions.localized/BENDR/
"""

import os
import sys
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

def generate_moef_xml(plugin_name, plugin_uuid, plugin_desc):
    return f"""<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE ozxmlscene>
<ozml version="5.5">

<displayversion>5.1</displayversion>

<factory id="1" uuid="46c844a813d311d8a438000a95af9f7e">
	<description>Channel</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="2" uuid="65cb4dc9d4504fa281921f5f751fba06">
	<description>Widget</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="3" uuid="66fc0d6af6a911d6a7a7000393670732">
	<description>Image</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="4" uuid="7d468273c013498e9806a0d7bc32fddf">
	<description>Project</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="5" uuid="deca4859b16011d7a12d0003936f6f92">
	<description>ProPlugin Filter</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<template>
	<flags>1</flags>
</template>

<build/>

<description>{plugin_desc}</description>

<scene>
	<sceneSettings>
		<width>1920</width>
		<height>1080</height>
		<duration>600</duration>
		<shouldOverrideFCDuration>0</shouldOverrideFCDuration>
		<frameRate>60</frameRate>
		<NTSC>1</NTSC>
		<channels>4</channels>
		<pixelAspectRatio>1</pixelAspectRatio>
		<backgroundColor red="0" green="0" blue="0" alpha="1"/>
		<audioChannels>2</audioChannels>
		<audioBitsPerSample>32</audioBitsPerSample>
		<fieldRenderingMode>0</fieldRenderingMode>
		<motionBlurSamples>8</motionBlurSamples>
		<motionBlurDuration>1</motionBlurDuration>
		<startTimecode>0</startTimecode>
		<backgroundMode>0</backgroundMode>
		<reflectionRecursionLimit>2</reflectionRecursionLimit>
		<glyphOSCMode>0</glyphOSCMode>
		<animateFlag>0</animateFlag>
		<parameterColorSpaceID>3</parameterColorSpaceID>
		<savePreviewMovie>0</savePreviewMovie>
	</sceneSettings>
	<currentFrame>0 1 1 0</currentFrame>
	<currentObject>10007</currentObject>
	<activeLayer>10003</activeLayer>
	<timeRange offset="0 1 1 0" duration="1201200 120000 1 0"/>
	<playRange offset="0 1 1 0" duration="1201200 120000 1 0"/>
	<flags>1</flags>
	<audioTracks>0</audioTracks>
	<timemarkerset/>
	<guideset/>
	<curvesets selected="1"/>
	<scenenode name="Project" id="10000" factoryID="4" version="5">
		<flags>0</flags>
		<timing in="0 1 1 0" out="-2002 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>16</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</scenenode>
	<layer name="Group" id="10003">
		<scenenode name="Effect Source" id="10007" factoryID="3" version="5">
			<validTracks>0</validTracks>
			<aspectRatio>0</aspectRatio>
			<flags>0</flags>
			<timing in="0 1 1 0" out="1199198 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>24576</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704">
				<parameter name="Media" id="324" flags="8589938704">
					<foldFlags>4</foldFlags>
					<parameter name="Source Media" id="300" flags="81621221392" default="10005" value="10005"/>
					<parameter name="Source Media" id="325" flags="8590000146">
						<referencedObjectID/>
					</parameter>
				</parameter>
				<parameter name="Page Number" id="301" flags="8589934610" default="1" value="1"/>
			</parameter>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Drop Zone" id="311" flags="8589934738" default="0" value="1"/>
				<parameter name="Drop Zone Type" id="321" flags="8590000146" default="0" value="3"/>
				<parameter name="Fill Opaque" id="328" flags="8606711824" default="0" value="0"/>
				<parameter name="Clear" id="315" flags="8606777360" default="0" value="0"/>
				<parameter name="Width" id="313" flags="8589934610" default="1" value="1920"/>
				<parameter name="Height" id="314" flags="8589934610" default="1" value="1080"/>
			</parameter>
			<filter name="{plugin_name}" id="10010" factoryID="5" pluginUUID="{plugin_uuid}" pluginVersion="1.0" pluginName="{plugin_name}" pluginDynamicParams="0">
				<timing in="0 1 1 0" out="1199198 120000 1 0" offset="0 1 1 0"/>
				<baseFlags>8589934609</baseFlags>
			</filter>
		</scenenode>
		<aspectRatio>1</aspectRatio>
		<flags>0</flags>
		<timing in="0 1 1 0" out="1199198 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704">
			<parameter name="Fixed Width" id="302" flags="12884901908" default="1920" value="1920"/>
			<parameter name="Fixed Height" id="303" flags="12884901908" default="1080" value="1080"/>
		</parameter>
	</layer>

	<footage name="Media Layer" id="10006">
		<clip name="Effect Source" id="10005">
			<pathURL>Drop Zone.tiff</pathURL>
			<missingWidth>600</missingWidth>
			<missingHeight>600</missingHeight>
			<missingDuration>0.033333333333333333</missingDuration>
			<creationDuration>1</creationDuration>
			<mediaID/>
			<flags>0</flags>
			<timing in="0 1 1 0" out="0 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>0</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704"/>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Pixel Aspect Ratio" id="104" flags="12884901888" default="1" value="1"/>
				<parameter name="Frame Rate" id="107" flags="8589934592" default="0" value="30"/>
				<parameter name="Fixed Width" id="114" flags="12884901888" default="600" value="600"/>
				<parameter name="Fixed Height" id="115" flags="12884901888" default="600" value="600"/>
			</parameter>
		</clip>
		<flags>0</flags>
		<timing in="0 1 1 0" out="-2002 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</footage>
</scene>

</ozml>
"""

def generate_motr_xml(plugin_name, plugin_uuid, plugin_desc):
    return f"""<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE ozxmlscene>
<ozml version="5.5">

<displayversion>5.1</displayversion>

<factory id="1" uuid="46c844a813d311d8a438000a95af9f7e">
	<description>Channel</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="2" uuid="65cb4dc9d4504fa281921f5f751fba06">
	<description>Widget</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="3" uuid="66fc0d6af6a911d6a7a7000393670732">
	<description>Image</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="4" uuid="7d468273c013498e9806a0d7bc32fddf">
	<description>Project</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="5" uuid="deca4859b16011d7a12d0003936f6f92">
	<description>ProPlugin Transition</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<template>
	<flags>1</flags>
</template>

<build/>

<description>{plugin_desc}</description>

<scene>
	<sceneSettings>
		<width>1920</width>
		<height>1080</height>
		<duration>30</duration>
		<shouldOverrideFCDuration>1</shouldOverrideFCDuration>
		<frameRate>30</frameRate>
		<NTSC>1</NTSC>
		<pixelAspectRatio>1</pixelAspectRatio>
		<backgroundColor red="0" green="0" blue="0" alpha="1"/>
		<audioChannels>2</audioChannels>
		<audioBitsPerSample>32</audioBitsPerSample>
		<fieldRenderingMode>0</fieldRenderingMode>
		<motionBlurSamples>8</motionBlurSamples>
		<motionBlurDuration>1</motionBlurDuration>
		<startTimecode>0</startTimecode>
		<backgroundMode>0</backgroundMode>
		<reflectionRecursionLimit>2</reflectionRecursionLimit>
		<glyphOSCMode>0</glyphOSCMode>
		<animateFlag>0</animateFlag>
		<parameterColorSpaceID>3</parameterColorSpaceID>
		<savePreviewMovie>0</savePreviewMovie>
	</sceneSettings>
	<timeRange offset="0 1 1 0" duration="120120 120000 1 0"/>
	<playRange offset="0 1 1 0" duration="120120 120000 1 0"/>
	<flags>1</flags>
	<audioTracks>0</audioTracks>
	<scenenode name="Project" id="10000" factoryID="4" version="5">
		<flags>0</flags>
		<timing in="0 1 1 0" out="-4004 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>16</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</scenenode>
	<layer name="Group" id="10003">
		<scenenode name="Transition A" id="10007" factoryID="3" version="5">
			<validTracks>1</validTracks>
			<aspectRatio>1</aspectRatio>
			<flags>0</flags>
			<timing in="0 1 1 0" out="116116 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>16384</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704">
				<parameter name="Media" id="324" flags="8589938704">
					<foldFlags>4</foldFlags>
					<parameter name="Source Media" id="300" flags="81621221392" default="988578780" value="988578780"/>
				</parameter>
			</parameter>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Drop Zone" id="311" flags="8589934738" default="0" value="1"/>
				<parameter name="Type" id="321" flags="8590000146" default="0" value="3"/>
			</parameter>
			<filter name="{plugin_name}" id="10010" factoryID="5" pluginUUID="{plugin_uuid}" pluginVersion="1.0" pluginName="{plugin_name}" pluginDynamicParams="0">
				<timing in="0 1 1 0" out="116116 120000 1 0" offset="0 1 1 0"/>
				<baseFlags>8589934608</baseFlags>
			</filter>
		</scenenode>
		<aspectRatio>1</aspectRatio>
		<flags>0</flags>
		<timing in="0 1 1 0" out="116116 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704">
			<parameter name="Fixed Width" id="302" flags="12884901908" default="1920" value="1920"/>
			<parameter name="Fixed Height" id="303" flags="12884901908" default="1080" value="1080"/>
		</parameter>
	</layer>

	<footage name="Media Layer" id="10006">
		<clip name="Drop Zone Transition A" id="988578780">
			<pathURL>Drop Zone Transition A.tiff</pathURL>
			<missingWidth>1920</missingWidth>
			<missingHeight>1080</missingHeight>
			<missingDuration>0.033333333333333333</missingDuration>
			<creationDuration>1</creationDuration>
			<flags>0</flags>
			<timing in="0 1 1 0" out="0 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>0</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704"/>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Pixel Aspect Ratio" id="104" flags="12884901888" default="1" value="1"/>
				<parameter name="Frame Rate" id="107" flags="8589934592" default="0" value="30"/>
				<parameter name="Fixed Width" id="114" flags="12884901888" default="1920" value="1920"/>
				<parameter name="Fixed Height" id="115" flags="12884901888" default="1080" value="1080"/>
			</parameter>
		</clip>
		<flags>0</flags>
		<timing in="0 1 1 0" out="116116 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</footage>
</scene>

</ozml>
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
        desc = p["desc"]

        if ptype == "transition":
            bundle_dir = transitions_dir / f"{name}"
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.motr"
            content = generate_motr_xml(name, uuid, desc)
        else:
            bundle_dir = effects_dir / f"{name}"
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.moef"
            content = generate_moef_xml(name, uuid, desc)

        with open(template_file, "w", encoding="utf-8") as f:
            f.write(content)

        print(f"  ✅ Installed: {name} -> {bundle_dir.relative_to(home)}")
        installed_count += 1

    print("==================================================")
    print(f"🎉 Successfully generated and installed {installed_count} templates!")
    print("==================================================")

if __name__ == "__main__":
    main()
