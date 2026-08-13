# Get in the apptainer with
# bash /data/snpit/env/environment_checkout_for_apptainer/singrun_smdc_ricksim.sh

pip install -e /home/packages/snappl
pip install -e /home/packages/campari
pip install -e /home/packages/phrosty
pip install -e /home/packages/sidecar
pip install roman-snpit-sfft

base_path=/ricksims/output_images_SCAx2_ZYJHF_40day/
base_path=/home/packages/photometry_test_data

template_path=${base_path}/SNPIT_VISIT602000033_WFI01_F106_L2.asdf
science_path=${base_path}/SNPIT_VISIT607000033_WFI01_F106_L2.asdf
python \
    packages/sidecar/sidecar/pipeline.py \
    --image-collection manual_rdm \
    --base-path ${base_path} \
    --template-path ${template_path} \
    --science-path ${science_path} \
    --no-reject-known-stars \
    --temp-dir ${HOME}/tmp \
    --output-dir ./ \
    --save-debug-products \
    --backend4subtract numpy

# The above will create the following output directory
# We should consider changing the way sidecar works so that the output directory 
# can be fully specified in the sidecar call,
# but for now we will just hardcode it here

SUBTRACTION_NAME=F106_607000033_1_-_F106_602000033_1
SIDECAR_OUT_DIR=${SUBTRACTION_NAME}
score_detection_file=${SIDECAR_OUT_DIR}/score_detection_${SUBTRACTION_NAME}.ecsv

# In MWV's testing on 2026-08-12, it was the third detection, but there's no order guarantee for the detected sources
# We need to skip over the comment lines in the ecsv file, which start with a # character
# and the header line with the column names
candidate_id_ra_dec=$(grep -v '^#' ${score_detection_file} | head -n 4 | tail -n 1 | awk '{print $1, $7, $8}')
sidecar_detection_id=$(echo ${candidate_id_ra_dec} | awk '{print $1}')
sidecar_ra=$(echo ${candidate_id_ra_dec} | awk '{print $2}')
sidecar_dec=$(echo ${candidate_id_ra_dec} | awk '{print $3}')

# SNPIT_CONFIG=packages/barcart/barcart/tests/phrosty_config_test_smdc.yaml
SNPIT_CONFIG=/home/packages/phrosty/examples/smdc/phrosty_config_smdc.yaml
SNPIT_SCRATCH=${HOME}/tmp
python packages/phrosty/phrosty/pipeline.py \
       --oid $sidecar_detection_id \
       --object-collection manual \
       --band J106 \
       --ra $sidecar_ra \
       --dec $sidecar_dec \
       --image-collection manual_rdm \
       --base-path ${base_path} \
       --template-images packages/barcart/barcart/tests/templates_1.csv \
       --science-images packages/barcart/barcart/tests/science_2.csv \
       --nprocs 1 --nwrite 1 \
       --backend numpy \
       -v


# salloc --nodes 1 --qos interactive --time 04:00:00 -p mem-med
# git checkout SMDC_updates
# export SNPIT_CONFIG=packages/barcart/barcart/tests/campari_config_test.yaml
export SNPIT_CONFIG=/home/packages/campari/examples/SMDC/campari_config_test.yaml

mkdir -p /dev_storage/campari_debug_dir/
python packages/campari/campari/RomanASP.py \
    --filter F106 \
    --ra $sidecar_ra \
    --dec $sidecar_dec \
    --diaobject-collection manual \
    --diaobject-name coolsne \
    --image-collection snpitdb \
    --image-provenance-tag ricksim202608 \
    --image-process load_ricksim \
    --transient_start 60400 \
    --nprocs  1  \
    --photometry-campari-psf-transient_class gaussian \
    --photometry-campari-psf-galaxy_class gaussian \
    --max_transient_images 1 \
    --max_no_transient_images 1 \
    --photometry-campari-grid_options-type regular \
    --no-save-to-db
