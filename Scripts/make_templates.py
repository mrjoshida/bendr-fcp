import xml.sax.saxutils
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
    return f"""<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE ozxmlscene>
<ozml version="5.11">

<displayversion>5.4.6.1</displayversion>

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

<factory id="4" uuid="6b337e9c21aa11d7a08700039375d2ba">
	<description>Master</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="5" uuid="7d468273c013498e9806a0d7bc32fddf">
	<description>Project</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="6" uuid="dbca752470fd11d7980100039389b702">
	<description>Channel</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<factory id="7" uuid="deca4859b16011d7a12d0003936f6f92">
	<description>ProPlugin Filter</description>
	<manufacturer>Apple</manufacturer>
	<version>1</version>
</factory>

<template>
	<flags>1</flags>
</template>

<build></build>

<description>{plugin_desc}</description>

<scene>
	<renderModel>1</renderModel>
	<sceneSettings>
		<width>1920</width>
		<height>1080</height>
		<duration>300</duration>
		<shouldOverrideFCDuration>0</shouldOverrideFCDuration>
		<frameRate>30</frameRate>
		<NTSC>1</NTSC>
		<pixelAspectRatio>1</pixelAspectRatio>
		<workingGamut>0</workingGamut>
		<viewGamut>-1</viewGamut>
		<optimizeForDisplay>0</optimizeForDisplay>
		<backgroundColor red="0" green="0" blue="0" alpha="1"/>
		<audioChannels>2</audioChannels>
		<audioBitsPerSample>32</audioBitsPerSample>
		<fieldRenderingMode>0</fieldRenderingMode>
		<motionBlurSamples>8</motionBlurSamples>
		<motionBlurDuration>1</motionBlurDuration>
		<sharpScaling>0</sharpScaling>
		<startTimecode>0</startTimecode>
		<backgroundMode>0</backgroundMode>
		<reflectionRecursionLimit>2</reflectionRecursionLimit>
		<glyphOSCMode>0</glyphOSCMode>
		<animateFlag>0</animateFlag>
		<parameterColorSpaceID>3</parameterColorSpaceID>
		<savePreviewMovie>0</savePreviewMovie>
		<Object3DEnvironments>100</Object3DEnvironments>
		<DRTSupport>1</DRTSupport>
	</sceneSettings>
	<publishSettings>
		<version>2</version>
		<target object="10010" channel="./10001" name="Mix"/>
	</publishSettings>
	<timeRange offset="0 1 1 0" duration="1201200 120000 1 0"/>
	<playRange offset="0 1 1 0" duration="1201200 120000 1 0"/>
	<flags>1</flags>
	<audioTracks>0</audioTracks>
	<timemarkerset>
		<timemarker>
			<inpoint>4004 120000 1 0</inpoint>
			<color>1</color>
			<type>7</type>
		</timemarker>
	</timemarkerset>
	<guideset/>
	<curvesets selected="1"/>
	<scenenode name="Project" id="10000" factoryID="5" version="5">
		<scenenode name="Widget" id="10002" factoryID="2" version="5">
			<flags>0</flags>
			<timing in="0 1 1 0" out="-4004 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>0</foldFlags>
			<baseFlags>16</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704"/>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Options" id="103" flags="8589938688"/>
				<parameter name="Hidden" id="102" flags="8589934608" default="0" value="1"/>
				<parameter name="Snapshots" id="101" flags="8589938706"/>
				<parameter name="Widget" id="100" flags="8589934608" default="1.7777777777777777" value="1.7777777777777777"/>
			</parameter>
		</scenenode>
		<flags>0</flags>
		<timing in="0 1 1 0" out="-4004 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>16</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704">
			<parameter name="HDR White Level" id="103" default="0.75" value="0.75"/>
		</parameter>
		<parameter name="Object" id="2" flags="8589938704"/>
	</scenenode>
	<layer name="Group" id="10003">
		<scenenode name="Effect Source" id="10007" factoryID="3" version="5">
			<validTracks>1</validTracks>
			<aspectRatio>1</aspectRatio>
			<flags>0</flags>
			<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>16384</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704">
				<parameter name="Lighting" id="230" flags="8589938706">
					<foldFlags>15</foldFlags>
				</parameter>
				<parameter name="Shadows" id="234" flags="8589938706">
					<foldFlags>15</foldFlags>
				</parameter>
				<parameter name="Reflection" id="223" flags="8589971474">
					<foldFlags>131087</foldFlags>
				</parameter>
				<parameter name="Media" id="324" flags="8589938704">
					<foldFlags>4</foldFlags>
					<parameter name="Source Media" id="300" flags="81621221392" default="999209238" value="999209238"/>
					<parameter name="Source Media" id="325" flags="8590000146"/>
				</parameter>
				<parameter name="Page Number" id="301" flags="8589934610" default="1" value="1"/>
				<parameter name="Retime Value" id="304" flags="8590066066">
					<curve type="1" default="1" value="1" round="0" retimingExtrapolation="1">
						<numberOfKeypoints>2</numberOfKeypoints>
						<keypoint interpolation="1" flags="0">
							<time>0 1 1 0</time>
							<value>1</value>
						</keypoint>
						<keypoint interpolation="1" flags="0">
							<time>1201200 120000 1 0</time>
							<value>301</value>
						</keypoint>
					</curve>
				</parameter>
				<parameter name="Retime Value Cache" id="319" flags="8590065810">
					<curve type="1" default="1" value="1">
						<numberOfKeypoints>2</numberOfKeypoints>
						<keypoint interpolation="1" flags="128">
							<time>0 1 1 0</time>
							<value>1</value>
						</keypoint>
						<keypoint interpolation="1" flags="128">
							<time>1201200 120000 1 0</time>
							<value>301</value>
						</keypoint>
					</curve>
				</parameter>
				<parameter name="Duration Cache" id="320" flags="8589934610" default="0" value="300"/>
			</parameter>
			<parameter name="Object" id="2" flags="8589938704">
				<parameter name="Drop Zone" id="311" flags="8589934738" default="0" value="1"/>
				<parameter name="Type" id="321" flags="8590000146" default="0" value="3"/>
				<parameter name="Pan" id="326" flags="77309415442">
					<foldFlags>15</foldFlags>
				</parameter>
				<parameter name="Scale" id="327" flags="77309415442">
					<foldFlags>15</foldFlags>
				</parameter>
				<parameter name="Fill Opaque" id="328" flags="8606711824" default="0" value="0"/>
				<parameter name="Fill Color" id="329" flags="8589938704">
					<foldFlags>15</foldFlags>
				</parameter>
				<parameter name="Clear" id="315" flags="8606777360" default="0" value="0"/>
				<parameter name="Width" id="313" flags="8589934610" default="1" value="1920"/>
				<parameter name="Height" id="314" flags="8589934610" default="1" value="1080"/>
			</parameter>
			<filter name="{plugin_name}" id="10010" factoryID="7" pluginUUID="{plugin_uuid}" pluginVersion="1.0" pluginName="{plugin_name}" pluginDynamicParams="1">
				<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
				<baseFlags>8589934608</baseFlags>
				<parameter name="Mix" id="10001" flags="12901679104" default="1" value="1"/>
			</filter>
		</scenenode>
		<aspectRatio>1</aspectRatio>
		<flags>0</flags>
		<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704">
			<parameter name="Lighting" id="230" flags="8589938706">
				<foldFlags>15</foldFlags>
			</parameter>
			<parameter name="Shadows" id="234" flags="8589938706">
				<foldFlags>15</foldFlags>
			</parameter>
			<parameter name="Reflection" id="223" flags="8589971474">
				<foldFlags>131087</foldFlags>
			</parameter>
		</parameter>
		<parameter name="Object" id="2" flags="8589938704">
			<parameter name="Fixed Width" id="302" flags="12884901908" default="1920" value="1920"/>
			<parameter name="Fixed Height" id="303" flags="12884901908" default="1080" value="1080"/>
			<parameter name="Flatten" id="311" flags="8589934610" default="0" value="0"/>
			<parameter name="Layer Order" id="305" flags="8589934610" default="0" value="0"/>
			<parameter name="Aperture Width" id="312" flags="12884901906" default="1920" value="1920"/>
			<parameter name="Aperture Height" id="313" flags="12884901906" default="1080" value="1080"/>
			<parameter name="New Fixed Res Behavior" id="315" flags="8594194480" default="1" value="0"/>
		</parameter>
	</layer>

	<audio name="Audio Layer" id="999209204">
		<scenenode name="Master" id="999209205" factoryID="4" version="5">
			<flags>0</flags>
			<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
			<foldFlags>0</foldFlags>
			<baseFlags>524304</baseFlags>
			<parameter name="Properties" id="1" flags="8589938704"/>
			<parameter name="Object" id="2" flags="8589938704"/>
		</scenenode>
		<flags>0</flags>
		<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</audio>

	<footage name="Media Layer" id="10006">
		<clip name="Drop Zone" id="999209238">
			<pathURL>Drop Zone.tiff</pathURL>
			<missingWidth>1200</missingWidth>
			<missingHeight>1200</missingHeight>
			<missingDuration>0.033333333333333333</missingDuration>
			<creationDuration>1</creationDuration>
			<mediaID></mediaID>
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
				<parameter name="Use Background Color" id="116" flags="8589934594" default="0" value="0"/>
				<parameter name="Background Color" id="117" flags="8589971458">
					<foldFlags>15</foldFlags>
					<parameter name="Red" id="1" flags="8589967376" default="1" value="1"/>
					<parameter name="Green" id="2" flags="8589967376" default="1" value="1"/>
					<parameter name="Blue" id="3" flags="8589967376" default="1" value="1"/>
				</parameter>
				<parameter name="Missing Is Still" id="128" flags="8589934610" default="0" value="1"/>
			</parameter>
		</clip>
		<flags>0</flags>
		<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
		<foldFlags>0</foldFlags>
		<baseFlags>524304</baseFlags>
		<parameter name="Properties" id="1" flags="8589938704"/>
		<parameter name="Object" id="2" flags="8589938704"/>
	</footage>
</scene>

</ozml>
"""

def generate_motr_xml(plugin_name, plugin_uuid, plugin_desc):
    return generate_moef_xml(plugin_name, plugin_uuid, plugin_desc)

def install_templates():
    user_home = Path.home()
    templates_base = user_home / "Movies" / "Motion Templates.localized"
    effects_dir = templates_base / "Effects.localized" / "BENDR"
    transitions_dir = templates_base / "Transitions.localized" / "BENDR"

    effects_dir.mkdir(parents=True, exist_ok=True)
    transitions_dir.mkdir(parents=True, exist_ok=True)

    print("==================================================")
    print("🎬 Generating Final Cut Pro Motion Templates (BENDR)")
    print("==================================================")

    for plugin in PLUGINS:
        name = plugin["name"]
        uuid = plugin["uuid"]
        desc = plugin["desc"]
        ptype = plugin["type"]

        if ptype == "effect":
            bundle_dir = effects_dir / name
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.moef"
            xml_content = generate_moef_xml(name, uuid, xml.sax.saxutils.escape(desc))
            category_rel = f"Movies/Motion Templates.localized/Effects.localized/BENDR/{name}"
        else:
            bundle_dir = transitions_dir / name
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.motr"
            xml_content = generate_motr_xml(name, uuid, xml.sax.saxutils.escape(desc))
            category_rel = f"Movies/Motion Templates.localized/Transitions.localized/BENDR/{name}"

        with open(template_file, "w", encoding="utf-8") as f:
            f.write(xml_content)

        print(f"  ✅ Installed: {name} -> {category_rel}")

    print("==================================================")
    print(f"🎉 Successfully generated and installed {len(PLUGINS)} templates!")
    print("==================================================")

if __name__ == "__main__":
    install_templates()
