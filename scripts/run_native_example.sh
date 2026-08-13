source /data/snpit/env/environment_checkout_for_native/smdc-native-shared.sh

export RUNDIR=${HOME}/snpit
# export SNPIT_DEFAULT_CONFIG=${SNPIT_DIR}/packages/environment/smdc_interactive_config.yaml
# export SNPIT_CONFIG=${SNPIT_DEFAULT_CONFIG}

pip install roman-snpit-sfft
pip install -e ${RUNDIR}/packages/snappl
pip install -e ${RUNDIR}/packages/campari
pip install -e ${RUNDIR}/packages/phrosty
pip install -e ${RUNDIR}/packages/sidecar --nodeps


base_path=/mnt/roman-science-east-2/snpit/snana+romanisim+romancal/output_images_SCAx2_ZYJHF_40day/
# base_path=${SNPIT_DIR}/packages/photometry_test_data

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
# We should change the way this works so that the output directory is specified in the sidecar call,
# but for now we will just hardcode it here

SUBTRACTION_NAME=F106_602000033_1_-_F106_607000033_1
SIDECAR_OUT_DIR=${SUBTRACTION_NAME}
score_detection_file=${SIDECAR_OUT_DIR}/score_detection_${SUBTRACTION_NAME}.ecsv

# For now we just take the first detection and run the photometry on it
# We need to skip over the comment lines in the ecsv file, which start with a # character
# and the header line with the column names
detection_id=$(grep -v '^#' ${score_detection_file} | head -n 2 | tail -n 1 | awk '{print $1, $5, $6}')

SNPIT_CONFIG=${SNPIT_DIR}/packages/barcart/barcart/tests/phrosty_config_smdc_singularity.yaml \
SNPIT_SCRATCH=${HOME}/tmp

python packages/phrosty/phrosty/pipeline.py \
       --oid 11 \
       -oc manual \
       -b J106 \
       -r 9.366435 \
       -d -43.958825 \
       -ic manual_rdm \
       --base-path ${base_path}
       -t packages/barcart/barcart/tests/templates_1.csv \
       -s packages/barcart/barcart/tests/science_2.csv \
       -p 1 -w 1 \
       --backend numpy \
       -v


# salloc --nodes 1 --qos interactive --time 04:00:00 -p mem-med
# git checkout SMDC_updates
export SNPIT_CONFIG=${SNPIT_DIR}/packages/barcart/barcart/tests/campari_config_test.yaml

mkdir -p /dev_storage/campari_debug_dir/
python packages/campari/campari/RomanASP.py \
    -f F106 \
    --ra 9.376416 \
    --dec -43.946209 \
    --diaobject-collection manual \
    --diaobject-name coolsne \
    --image-collection snpitdb \
    --image-provenance-tag ricksim202608 \
    --image-process load_ricksim \
    --transient_start 60400 \
    --nprocs  1  \
    --photometry-campari-psf-transient_class gaussian \
    --photometry-campari-psf-galaxy_class gaussian \
    -t 1 -n 1 \
    --photometry-campari-grid_options-type regular \
    --no-save-to-db

