# Get in the apptainer with the following command to be run from
# your RUNDIR, which is defined to be the directory that contains 'packages/'
#
# source /data/snpit/env/environment_checkout_for_apptainer/singrun_smdc_ricksim.sh
#
# Then from that shell you can run this script with
#
# bash barcart/scripts/run_apptainer_example.sh

RUNDIR=/home
BASE_IMAGE_PATH=/ricksims

bash ${RUNDIR}/packages/barcart/scripts/run_example.sh ${RUNDIR} ${BASE_IMAGE_PATH}
