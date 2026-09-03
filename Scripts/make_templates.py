#!/usr/bin/env python3
"""
make_templates.py — Generates Final Cut Pro Motion Templates for all 14 BENDR plugins
and their curated preset looks.

Installs templates to:
- ~/Movies/Motion Templates.localized/Effects.localized/BENDR/
- ~/Movies/Motion Templates.localized/Effects.localized/BENDR - <Category>/
- ~/Movies/Motion Templates.localized/Transitions.localized/BENDR/
- ~/Movies/Motion Templates.localized/Transitions.localized/BENDR - Transitions/
"""

import os
import sys
import xml.sax.saxutils
from pathlib import Path

# Import presets data
sys.path.insert(0, str(Path(__file__).resolve().parent))
try:
    from presets_data import PRESETS
except ImportError:
    PRESETS = []

# Base plugin metadata
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

UUID_MAP = {p["name"]: p["uuid"] for p in PLUGINS}
TYPE_MAP = {p["name"]: p["type"] for p in PLUGINS}

def get_params_for_plugin(name):
    clean_name = name.replace(' ', '')
    base_dir = Path(__file__).resolve().parent.parent
    filter_file = base_dir / f"{clean_name}Service" / f"{clean_name}Filter.swift"
    param_file = base_dir / f"{clean_name}Service" / f"{clean_name}Params.swift"
    id_map = {}
    if not param_file.exists() or not filter_file.exists():
        return []
    import re
    with open(param_file, "r", encoding="utf-8") as fp:
        p_text = fp.read()
    for m in re.finditer(r'case\s+(\w+)\s*=\s*(\d+)', p_text):
        id_map[m.group(1)] = int(m.group(2))
    with open(filter_file, "r", encoding="utf-8") as fp:
        f_text = fp.read()
    params = []
    
    # Floats
    p_float = r'addFloatSlider\(withName:\s*\"([^\"]+)\",\s*parameterID:\s*\w+ParamID\.(\w+)\.rawValue,\s*defaultValue:\s*([0-9\.\-]+)'
    for m in re.finditer(p_float, f_text):
        pname = m.group(1)
        enum_case = m.group(2)
        default_val = float(m.group(3))
        param_id = id_map.get(enum_case)
        if param_id:
            params.append({'name': pname, 'enum': enum_case, 'id': param_id, 'default': default_val, 'type': 'float'})
            
    # Ints
    p_int = r'addIntSlider\(withName:\s*\"([^\"]+)\",\s*parameterID:\s*\w+ParamID\.(\w+)\.rawValue,\s*defaultValue:\s*([0-9\-]+)'
    for m in re.finditer(p_int, f_text):
        pname = m.group(1)
        enum_case = m.group(2)
        default_val = int(m.group(3))
        param_id = id_map.get(enum_case)
        if param_id:
            params.append({'name': pname, 'enum': enum_case, 'id': param_id, 'default': default_val, 'type': 'int'})
            
    # Popup Menus
    p_popup = r'addPopupMenu\(withName:\s*\"([^\"]+)\",\s*parameterID:\s*\w+ParamID\.(\w+)\.rawValue,\s*defaultValue:\s*(\d+)'
    for m in re.finditer(p_popup, f_text):
        pname = m.group(1)
        enum_case = m.group(2)
        default_val = int(m.group(3))
        param_id = id_map.get(enum_case)
        if param_id:
            params.append({'name': pname, 'enum': enum_case, 'id': param_id, 'default': default_val, 'type': 'menu'})
            
    # Toggles
    p_toggle = r'addToggleButton\(withName:\s*\"([^\"]+)\",\s*parameterID:\s*\w+ParamID\.(\w+)\.rawValue,\s*defaultValue:\s*(true|false)'
    for m in re.finditer(p_toggle, f_text):
        pname = m.group(1)
        enum_case = m.group(2)
        default_val = 1 if m.group(3) == 'true' else 0
        param_id = id_map.get(enum_case)
        if param_id:
            params.append({'name': pname, 'enum': enum_case, 'id': param_id, 'default': default_val, 'type': 'toggle'})
            
    return params

def generate_moef_xml(plugin_name, plugin_uuid, plugin_desc, params=None, overrides=None):
    if params is None:
        params = []
    if overrides is None:
        overrides = {}
    
    publish_targets = ['\t\t<target object="10010" channel="./10001" name="Mix"/>']
    param_nodes = ['\t\t\t\t<parameter name="Mix" id="10001" flags="12901679104" default="1" value="1"/>']
    
    for p in params:
        p_name = xml.sax.saxutils.escape(p['name'])
        p_id = p['id']
        p_def = p['default']
        p_enum = p.get('enum', '')
        p_type = p.get('type', 'float')
        
        # Look up override by enum name or display name
        val = overrides.get(p_enum, overrides.get(p['name'], p_def))
        
        publish_targets.append(f'\t\t<target object="10010" channel="./{p_id}" name="{p_name}"/>')
        if p_type == 'menu':
            param_nodes.append(f'\t\t\t\t<parameter name="{p_name}" id="{p_id}" flags="8606777360" default="{int(p_def)}" value="{int(val)}"/>')
        elif p_type in ('int', 'toggle'):
            param_nodes.append(f'\t\t\t\t<parameter name="{p_name}" id="{p_id}" flags="8606711824" default="{int(p_def)}" value="{int(val)}"/>')
        else:
            param_nodes.append(f'\t\t\t\t<parameter name="{p_name}" id="{p_id}" flags="8606711824" default="{p_def}" value="{val}"/>')

    publish_xml = "\n".join(publish_targets)
    params_xml = "\n".join(param_nodes)
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
{publish_xml}
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
			<filter name="{plugin_name}" id="10010" factoryID="7" pluginUUID="{plugin_uuid}" pluginVersion="1.0" pluginName="{plugin_name}" pluginDynamicParams="0">
				<timing in="0 1 1 0" out="1197196 120000 1 0" offset="0 1 1 0"/>
				<baseFlags>8589934608</baseFlags>
{params_xml}
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

def generate_motr_xml(plugin_name, plugin_uuid, plugin_desc, params=None, overrides=None):
    return generate_moef_xml(plugin_name, plugin_uuid, plugin_desc, params, overrides)

def install_templates():
    user_home = Path.home()
    templates_base = user_home / "Movies" / "Motion Templates.localized"
    effects_base = templates_base / "Effects.localized"
    transitions_base = templates_base / "Transitions.localized"

    effects_base.mkdir(parents=True, exist_ok=True)
    transitions_base.mkdir(parents=True, exist_ok=True)

    print("==================================================")
    print("🎬 Generating Final Cut Pro Motion Templates (BENDR)")
    print("==================================================")

    # 1. Base Plugin Templates (Default Looks)
    print("\n--- 1. Generating 14 Base Plugin Templates ---")
    param_cache = {}
    for plugin in PLUGINS:
        name = plugin["name"]
        uuid = plugin["uuid"]
        desc = plugin["desc"]
        ptype = plugin["type"]
        params = get_params_for_plugin(name)
        param_cache[name] = params

        if ptype == "effect":
            bundle_dir = effects_base / "BENDR" / name
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.moef"
            xml_content = generate_moef_xml(name, uuid, xml.sax.saxutils.escape(desc), params)
            category_rel = f"Effects/BENDR/{name}"
        else:
            bundle_dir = transitions_base / "BENDR" / name
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{name}.motr"
            xml_content = generate_motr_xml(name, uuid, xml.sax.saxutils.escape(desc), params)
            category_rel = f"Transitions/BENDR/{name}"

        with open(template_file, "w", encoding="utf-8") as f:
            f.write(xml_content)

        print(f"  ✅ Installed Core: {name} ({len(params)} params) -> {category_rel}")

    # 2. Curated Preset Templates
    print(f"\n--- 2. Generating {len(PRESETS)} Curated Preset Templates ---")
    preset_count = 0
    for preset in PRESETS:
        p_name = preset["name"]
        plugin_name = preset["plugin"]
        category = preset.get("category", f"BENDR - {plugin_name.replace('BENDR ', '')}")
        desc = preset.get("desc", f"Preset: {p_name}")
        overrides = preset.get("params", {})
        
        uuid = UUID_MAP.get(plugin_name)
        ptype = TYPE_MAP.get(plugin_name, "effect")
        params = param_cache.get(plugin_name, [])
        if not uuid or not params:
            continue

        template_title = f"{plugin_name} — {p_name}"
        if ptype == "effect":
            cat_dir = effects_base / category
            bundle_dir = cat_dir / template_title
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{template_title}.moef"
            xml_content = generate_moef_xml(plugin_name, uuid, xml.sax.saxutils.escape(desc), params, overrides)
            cat_rel = f"Effects/{category}/{template_title}"
        else:
            cat_dir = transitions_base / category
            bundle_dir = cat_dir / template_title
            bundle_dir.mkdir(parents=True, exist_ok=True)
            template_file = bundle_dir / f"{template_title}.motr"
            xml_content = generate_motr_xml(plugin_name, uuid, xml.sax.saxutils.escape(desc), params, overrides)
            cat_rel = f"Transitions/{category}/{template_title}"

        with open(template_file, "w", encoding="utf-8") as f:
            f.write(xml_content)

        preset_count += 1
        print(f"  ✨ Installed Preset: {template_title} -> {cat_rel}")

    print("==================================================")
    print(f"🎉 Successfully installed {len(PLUGINS)} Core Plugins + {preset_count} Presets ({len(PLUGINS) + preset_count} Total Templates)!")
    print("==================================================")

if __name__ == "__main__":
    install_templates()
