#!/usr/bin/env bash
# SPDX-License-Identifier: EUPL-1.2
# SPDX-FileCopyrightText: 2025-present Jürgen Mülbert
# This script reads coverage.xml and generates a JSON badge for GitHub.

set -euo pipefail

# Check coverage.xml exists
if [[ ! -f "coverage.xml" ]]; then
  echo "Error: coverage.xml not found."
  exit 1
fi

# Extract coverage percentage (line-rate) from coverage.xml
COVERAGE_PERCENTAGE=$(python -c "
import xml.etree.ElementTree as ET
tree = ET.parse('coverage.xml')
root = tree.getroot()
line_rate = float(root.get('line-rate', 0))
print(line_rate)
")

# Determine badge color
COLOR="red"
if (($(echo "$COVERAGE_PERCENTAGE >= 0.8" | bc -l))); then
  COLOR="green"
elif (($(echo "$COVERAGE_PERCENTAGE >= 0.5" | bc -l))); then
  COLOR="orange"
fi

# Format percentage as integer for badge
PERCENT_INT=$(printf "%.0f" "$(echo "$COVERAGE_PERCENTAGE * 100" | bc -l)")

# Ensure badge folder exists
mkdir -p .github/badges

# Write badge JSON
cat >.github/badges/coverage.json <<EOF
{
  "schemaVersion": 1,
  "label": "coverage",
  "message": "${PERCENT_INT}%",
  "color": "${COLOR}"
}
EOF
