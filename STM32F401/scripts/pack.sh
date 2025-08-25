#!/bin/bash

# Version: 1.2
# Date: 2025-07-08
# CMSIS Software Pack Generation Script

set -euo pipefail

#---------------------------------------------
# Arguments and checks
#---------------------------------------------
CONFIG_FILE="${1:-}"
if [ -z "$CONFIG_FILE" ] || [ ! -f "$CONFIG_FILE" ]; then
  echo "Usage: $0 <Pack.json>"
  exit 1
fi

command -v jq >/dev/null || { echo "Error: jq is required but not found in PATH."; exit 1; }
command -v PackChk >/dev/null || { echo "Error: PackChk not found in PATH."; exit 1; }

if [[ "$(uname -s)" == "Linux" ]]; then
  command -v xmllint >/dev/null || echo "Warning: xmllint not found. Schema validation will be skipped."
fi

#---------------------------------------------
# Load config from JSON
#---------------------------------------------
PACK_VENDOR=$(jq -r '.PACK_VENDOR' "$CONFIG_FILE")
PACK_NAME=$(jq -r '.PACK_NAME' "$CONFIG_FILE")
PACK_DIRS=($(jq -r '.PACK_DIRS[]?' "$CONFIG_FILE"))
PACK_BASE_FILES=($(jq -r '.PACK_BASE_FILES[]?' "$CONFIG_FILE"))
PDSC_FILES=($(jq -r '.PDSC_FILES[]?' "$CONFIG_FILE"))
PACK_WAREHOUSE=$(jq -r '.PACK_WAREHOUSE // "output"' "$CONFIG_FILE")

CONFIG_DIR=$(dirname "$(realpath "$CONFIG_FILE")") 

#---------------------------------------------
# Determine PDSC file
#---------------------------------------------
if [ "${#PDSC_FILES[@]}" -eq 0 ]; then
  # Fallback to ../resources/*.pdsc if none specified in JSON
  PDSC_FILES=(../resources/*.pdsc)
fi

if (( ${#PDSC_FILES[@]} == 0 )); then
  echo "Error: No .pdsc file found (neither in JSON nor in ../resources/)."
  exit 1
elif (( ${#PDSC_FILES[@]} > 1 )); then
  echo "Error: Multiple .pdsc files found. Only one is allowed:"
  printf '  %s\n' "${PDSC_FILES[@]}"
  exit 1
fi

PDSC_FILE="${PDSC_FILES[0]}"
echo "Using PDSC file: $PDSC_FILE"

#---------------------------------------------
# Setup directories
#---------------------------------------------
PACK_BUILD="build"

rm -rf "$PACK_BUILD"
mkdir -p "$PACK_BUILD"
cp -f "$PDSC_FILE" "$PACK_BUILD/"

# Copy directories preserving structure
echo "Copying directories..."
for dir in "${PACK_DIRS[@]:-}"; do
  if [[ -d "$dir" ]]; then
    cp -r "$dir" "$PACK_BUILD/"
  else
    echo "Warning: directory not found: $dir"
  fi
done

# Define relpath function for cross-platform relative paths
relpath() {
  python3 -c "import os.path; print(os.path.relpath('$1', '$2'))"
}

# Copy base files preserving structure
echo "Copying base files..."
for file in "${PACK_BASE_FILES[@]}"; do
  SRC_FILE="$CONFIG_DIR/$file"
  clean_path="${file#./}"
  clean_path="${clean_path##../}"
  
  if [[ -f "$SRC_FILE" ]]; then
    DST_FILE="$PACK_BUILD/$clean_path"
    echo "Copying src=$SRC_FILE dst=$DST_FILE"
    mkdir -p "$(dirname "$DST_FILE")"
    cp -f "$SRC_FILE" "$DST_FILE"
  else
    echo "Warning: base file not found: $SRC_FILE"
  fi
done


# Verify copied files
for file in "${PACK_BASE_FILES[@]}"; do
  SRC_FILE="$CONFIG_DIR/$file"
  clean_path="${file#./}"
  clean_path="${clean_path##../}"
  DST_FILE="$PACK_BUILD/$clean_path"
  if [[ ! -f "$DST_FILE" ]]; then
    echo "Error: Expected file missing after copy: $DST_FILE"
    exit 1
  fi
done



#---------------------------------------------
# Schema validation (Linux only)
#---------------------------------------------
if [[ "$(uname -s)" == "Linux" && -n "${CMSIS_PACK_PATH:-}" ]]; then
  if [[ -f "${CMSIS_PACK_PATH}/CMSIS/Utilities/PACK.xsd" ]]; then
    echo "Running schema validation with xmllint..."
    xmllint --noout --schema "${CMSIS_PACK_PATH}/CMSIS/Utilities/PACK.xsd" "$PACK_BUILD/$(basename "$PDSC_FILE")"
  else
    echo "Warning: PACK.xsd not found at \$CMSIS_PACK_PATH"
  fi
else
  echo "Schema validation skipped (non-Linux or CMSIS_PACK_PATH not set)"
fi

#---------------------------------------------
# Run PackChk
#---------------------------------------------
echo "Running PackChk..."
PackChk "$PACK_BUILD/$(basename "$PDSC_FILE")" -n PackName.txt -x M362
PACKNAME=$(<PackName.txt)
rm -f PackName.txt

#---------------------------------------------
# Create output directory and archive pack
#---------------------------------------------
mkdir -p "$PACK_WAREHOUSE"
echo "Creating pack archive: $PACK_WAREHOUSE/$PACKNAME"

if [[ "$(uname -s)" == "Darwin" ]]; then
  command -v zip >/dev/null || { echo "Error: zip not found in PATH."; exit 1; }
  (
    cd "$PACK_BUILD" || exit 1
    zip -r "../$PACK_WAREHOUSE/$PACKNAME" . >/dev/null
  )
else
  command -v 7z >/dev/null || { echo "Error: 7z not found in PATH."; exit 1; }
  (
    cd "$PACK_BUILD" || exit 1
    7z a "../$PACK_WAREHOUSE/$PACKNAME" -tzip >/dev/null
  )
fi

echo "Pack successfully created: $PACK_WAREHOUSE/$PACKNAME"

#---------------------------------------------
# Clean up
#---------------------------------------------
rm -rf "$PACK_BUILD"
echo "Build complete: $(date)"
