#!/bin/bash
set -e

# run_suite.sh — Master automated test runner for BENDR Final Cut Pro suite

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=================================================="
echo "🧪 BENDR Final Cut Pro Automated Test Suite"
echo "=================================================="
echo "Target: $ROOT_DIR"
echo ""

cd "$ROOT_DIR"

# Step 1: Validate Parameter Struct Alignment & Memory Layouts
echo "--- 1. Parameter Struct Memory Alignment Test ---"
swift "$SCRIPT_DIR/test_struct_alignments.swift"
echo ""

# Step 2: Run Headless GPU Compute Tests (All 14 Shaders on Metal)
echo "--- 2. Live Metal GPU Compute & Pipeline Execution Test ---"
swiftc -O "$SCRIPT_DIR/headless_render_test.swift" -o /tmp/bendr_headless_test
/tmp/bendr_headless_test
rm -f /tmp/bendr_headless_test
echo ""

# Step 3: Generate Motion Templates
echo "--- 3. Final Cut Pro Motion Template Generator ---"
python3 "$SCRIPT_DIR/make_templates.py"
echo ""

echo "=================================================="
echo "🎉 ALL BENDR AUTOMATED TESTS PASSED (14/14 PLUGINS OK)!"
echo "=================================================="
