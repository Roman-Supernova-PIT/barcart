#!/usr/bin/env bash
set -Eeuo pipefail

# This script is meant to be run by invoking either 'run_native_example.sh' or 'run_apptainer_example.sh'

usage() {
  echo "Usage: $0 RUNDIR BASE_IMAGE_PATH" >&2
  exit 1
}

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"
}

require_file() {
  local path="$1"
  local label="$2"
  if [[ ! -e "$path" ]]; then
    echo "ERROR: ${label} not found: ${path}" >&2
    exit 1
  fi
}

require_arg() {
  local value="$1"
  local name="$2"
  if [[ -z "$value" ]]; then
    echo "ERROR: ${name} is empty" >&2
    exit 1
  fi
}

[[ $# -eq 2 ]] || usage

RUNDIR="$1"
BASE_IMAGE_PATH="$2"

require_arg "$RUNDIR" "RUNDIR"
require_arg "$BASE_IMAGE_PATH" "BASE_IMAGE_PATH"

if [[ ! -d "${RUNDIR}/packages" ]]; then
  echo "ERROR: RUNDIR must contain a packages/ directory: ${RUNDIR}" >&2
  exit 1
fi

if [[ ! -d "$BASE_IMAGE_PATH" ]]; then
  echo "ERROR: BASE_IMAGE_PATH does not exist: ${BASE_IMAGE_PATH}" >&2
  exit 1
fi

export RUNDIR BASE_IMAGE_PATH
cd "$RUNDIR"

SNPIT_CONFIG="${RUNDIR}/packages/barcart/scripts/barcart_config_test.yaml"
require_file "$SNPIT_CONFIG" "SNPIT config"

# These are package requirements that should eventually live in package metadata.
log "Installing required Python dependencies"
python -m pip install --quiet crds sfft-romansnpit

# 2026-08-14: Hopefully not needed once snappl settles down.
python -m pip install --quiet -e "${RUNDIR}/packages/snappl"
python -m pip install --quiet -e "${RUNDIR}/packages/campari"
python -m pip install --quiet -e "${RUNDIR}/packages/phrosty" --no-deps
python -m pip install --quiet -e "${RUNDIR}/packages/sidecar" --no-deps

template_path="${BASE_IMAGE_PATH}/output_images_SCAx2_ZYJHF_40day/SNPIT_VISIT602000033_WFI01_F106_L2.asdf"
science_path="${BASE_IMAGE_PATH}/output_images_SCAx2_ZYJHF_40day/SNPIT_VISIT607000033_WFI01_F106_L2.asdf"
require_file "$template_path" "template image"
require_file "$science_path" "science image"

log "Running sidecar subtraction"
python \
  packages/sidecar/sidecar/pipeline.py \
  --image-collection manual_rdm \
  --base-path "$BASE_IMAGE_PATH" \
  --template-path "$template_path" \
  --science-path "$science_path" \
  --no-reject-known-stars \
  --temp-dir "${HOME}/tmp" \
  --output-dir ./ \
  --backend4subtract numpy

# The above creates the following output directory.
# We should consider changing the way sidecar works so that the output directory
# can be fully specified in the sidecar call, but for now we hardcode it here.
SUBTRACTION_NAME="F106_607000033_1_-_F106_602000033_1"
SIDECAR_OUT_DIR="${SUBTRACTION_NAME}"
score_detection_file="${SIDECAR_OUT_DIR}/score_detection_${SUBTRACTION_NAME}.ecsv"
require_file "$score_detection_file" "sidecar detection file"

# In MWV's testing on 2026-08-12, it was the third detection, but there is no
# order guarantee for the detected sources. Parse the data through package code
# instead of an inline Python block so the logic is reusable and easier to test.
read -r sidecar_detection_id sidecar_ra sidecar_dec < <(
  python -m barcart.detection_parser "$score_detection_file"
)

require_arg "$sidecar_detection_id" "sidecar_detection_id"
require_arg "$sidecar_ra" "sidecar_ra"
require_arg "$sidecar_dec" "sidecar_dec"

log "Running phrosty for oid=${sidecar_detection_id}"
SNPIT_SCRATCH="${HOME}/tmp"
export SNPIT_SCRATCH
python packages/phrosty/phrosty/pipeline.py \
  --oid "$sidecar_detection_id" \
  --object-collection manual \
  --band J129 \
  --ra "$sidecar_ra" \
  --dec "$sidecar_dec" \
  --image-collection manual_rdm \
  --base-path "$BASE_IMAGE_PATH" \
  --template-images "${RUNDIR}/packages/barcart/barcart/tests/templates_1.csv" \
  --science-images "${RUNDIR}/packages/barcart/barcart/tests/science_2.csv" \
  --nprocs 1 \
  --nwrite 1 \
  --backend numpy \
  -v

mkdir -p /dev_storage/campari_debug_dir/
log "Running campari"
python packages/campari/campari/RomanASP.py \
  --filter F129 \
  --ra "$sidecar_ra" \
  --dec "$sidecar_dec" \
  --diaobject-collection manual \
  --diaobject-name coolsne \
  --image-collection snpitdb \
  --image-provenance-tag ricksim202608 \
  --image-process load_ricksim \
  --transient_start 60400 \
  --nprocs 1 \
  --photometry-campari-psf-transient_class gaussian \
  --photometry-campari-psf-galaxy_class gaussian \
  --max_transient_images 1 \
  --max_no_transient_images 1 \
  --photometry-campari-grid_options-type regular \
  --no-save-to-db
