#!/bin/bash
#
# Set SGE
#
#$ -S /bin/bash # set shell in UGE
#$ -o log
#$ -e log
#$ -cwd         # execute at the submitted dir
pwd             # print current working directory
hostname        # print hostname
date            # print date



#
# ANCE pipeline
#

#R_BIN=/usr/local/package/r/3.0.2_icc_mkl/bin/R 
R_BIN=/usr/local/package/r/2.15.3_icc_mkl/bin/R 
ACNE_SRC=ACNE.R

######################################################################
# Data Structure
#
# <Working dir>
# +- annotationData/ 
#    +- chipTypes/ 
#      +- <chipTypeA>/ 
#         +- CDF files for this chipTypeA
# 
# +- rawData/ 
#    +- <dataSet1>/ 
#      +- <chipTypeA>/ 
#         +- CEL files
#
# +- <outputDir>
#    +- <dataSet1>
#       +- <chipTypeA>
#
######################################################################
# You need to specify
#   chip type,
#   sample directory name( dataSet1 ),
#   output direcotry
CHIP="GenomeWideSNP_6"
SAMPLE_NAME="VENUE"
OUTPUT_DIR="output"

echo "######################################################################"
echo "Run ACNE analysis on"
echo "Sample data dir:  ${SAMPLE_NAME}"
echo "R Source file:    ${ACNE_SRC}"
echo "R binary:         ${R_BIN}"
echo "Output dir:       ${OUTPUT_DIR}"
echo "Input data dir:   ${OUTPUT_DIR}/${SAMPLE_NAME}/${CHIP}"

######################################################################
#
# Log files and shell script files are found at 'log' direcotry
#
perl  ./run_ACNE.pl \
        --chip ${CHIP} \
        --output_dir ${OUTPUT_DIR} \
        --sample_dir ${SAMPLE_NAME} \
        --r_binary ${R_BIN} \
        --r_src ${ACNE_SRC}

if [ "$?" != "0" ]
then
    echo "run_ACNE.pl failed."
    exit $?
fi

echo "Now to start merging output files."

WORK_DIR=${OUTPUT_DIR}/${SAMPLE_NAME}/${CHIP}
rm ${WORK_DIR}/All.tab*

FILES=`ls ${WORK_DIR}/*.tab`
for FILE in ${FILES}
do
    BASE_NAME=`basename ${FILE}`
    FILE_NAMES="${FILE_NAMES}	${BASE_NAME}"
done
echo "${FILE_NAMES}" > ${WORK_DIR}/All.tab

FIRST_FILE=`echo ${FILES} | cut -d" " -f1`
awk 'NR==1{ print "" } NR>1{ print $1 }' ${FIRST_FILE} > ${WORK_DIR}/All.tab.1

FILE_OUT=${WORK_DIR}/All.tab.1

for FILE in ${FILES}
do
    BASE_NAME=`basename ${FILE}`
    awk 'NR==1{ print $1 "\t" $2} NR>1{ print $2 "\t" $3 }' ${FILE} > ${WORK_DIR}/All.tab.${BASE_FILE}
    FILE_OUT="${FILE_OUT} ${WORK_DIR}/All.tab.${BASE_FILE}"
done

paste ${FILE_OUT} >> ${WORK_DIR}/All.tab

rm ${WORK_DIR}/All.tab.*

echo "The output data is available at ${WORK_DIR}."
echo "The merged file is ${WORK_DIR}/All.tab."
echo "Finished!"
