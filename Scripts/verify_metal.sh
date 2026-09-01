#!/bin/bash
set -e

# verify_metal.sh — Compiles and validates all Metal shaders in the BENDR suite
echo "=================================================="
echo "⚡ BENDR Metal Shader Compilation & Syntax Test"
echo "=================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
TEMP_DIR="/tmp/bendr_metal_test"

rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

METAL_FILES=(
    "Shared/Metal/BendrBlends.metal"
    "BENDRVHSService/Metal/BENDRVHS.metal"
    "BENDRCRTService/Metal/BENDRCRT.metal"
    "BENDRFeedbackService/Metal/BENDRFeedback.metal"
    "BENDRColourService/Metal/BENDRColour.metal"
    "BENDRScanService/Metal/BENDRScan.metal"
    "BENDRCorruptService/Metal/BENDRCorrupt.metal"
    "BENDRMeltService/Metal/BENDRMelt.metal"
    "BENDRDirtyService/Metal/BENDRDirty.metal"
    "BENDRFlowService/Metal/BENDRFlow.metal"
    "BENDRSignalLabService/Metal/BENDRSignalLab.metal"
    "BENDRSynthService/Metal/BENDRSynth.metal"
    "BENDRTransitionService/Metal/BENDRTransition.metal"
    "BENDRSpatialService/Metal/BENDRSpatial.metal"
    "BENDROpticsService/Metal/BENDROptics.metal"
)

PASSED=0
FAILED=0
AIR_FILES=()

for rel_path in "${METAL_FILES[@]}"; do
    full_path="$ROOT_DIR/$rel_path"
    base_name="$(basename "$rel_path" .metal)"
    out_air="$TEMP_DIR/${base_name}.air"

    if [ ! -f "$full_path" ]; then
        echo "❌ MISSING: $rel_path"
        FAILED=$((FAILED + 1))
        continue
    fi

    echo -n "  Compiling $(printf '%-30s' "$rel_path")... "
    if xcrun -sdk macosx metal -c -I "$ROOT_DIR/Shared/Metal" "$full_path" -o "$out_air" 2>"$TEMP_DIR/${base_name}.log"; then
        echo "✅ OK"
        PASSED=$((PASSED + 1))
        if [ "$base_name" != "BendrBlends" ]; then
            AIR_FILES+=("$out_air")
        fi
    else
        echo "❌ FAILED"
        cat "$TEMP_DIR/${base_name}.log"
        FAILED=$((FAILED + 1))
    fi
done

echo ""
echo "--- Linking Shaders into Unified Test Metallib ---"
if [ ${#AIR_FILES[@]} -gt 0 ]; then
    if xcrun -sdk macosx metallib "${AIR_FILES[@]}" -o "$TEMP_DIR/bendr_test.metallib"; then
        echo "✅ Successfully linked ${#AIR_FILES[@]} shaders into $TEMP_DIR/bendr_test.metallib"
    else
        echo "❌ Metallib link failed"
        FAILED=$((FAILED + 1))
    fi
fi

echo "=================================================="
echo "Metal Verification Result: $PASSED passed, $FAILED failed"
echo "=================================================="

if [ $FAILED -gt 0 ]; then
    exit 1
fi
