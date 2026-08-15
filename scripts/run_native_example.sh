RUNDIR=${HOME}/snpit
BASE_IMAGE_PATH=/mnt/roman-science-east-2/snpit/snana+romanisim+romancal

source ${RUNDIR}/packages/environment/smdc-native-individual.sh

bash ${RUNDIR}/packages/barcart/scripts/run_example.sh ${RUNDIR} ${BASE_IMAGE_PATH}
