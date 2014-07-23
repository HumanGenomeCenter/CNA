#!/bin/bash
#
# ASCAT pipeline
#
#$ -S /bin/bash # set shell in UGE
#$ -o /home/eigos/Log
#$ -e /home/eigos/Log
#$ -cwd         # execute at the submitted dir


pwd             # print current working directory
hostname        # print hostname
date            # print date
echo arg1=$1    # print 1st argument of shell script
date            # print date

#set -xv

R_BIN=/usr/local/package/r/3.0.2_icc_mkl/bin/R 
#R_BIN=/usr/local/package/r/2.15.3_icc_mkl/bin/R 
ASCAT_SRC=script/ASCAT.R

#
# Assumed input directory
#
# input/<sample name>/<file name>
#

#
# Input file setup
#    BAFn.txt
#    BAFt.txt
#    LogRn.txt
#    LogRt.txt
COLUMN_START=11
COLUMN_END=12

EX_DIR="Example_${COLUMN_START}-${COLUMN_END}"

#
# R options
#
DATA_TYPE='matched_data'
CHR_LIST='1:22'
SNP6_OPTION='SNP6'

OUTPUT_PREFIX=${EX_DIR}
SAMPLE_NAME=${EX_DIR}


######################################################################
#
# If the specified input data is not available, make it.
#
BASE_FILES="
    BAFn.txt
    BAFt.txt
    LogRn.txt
    LogRt.txt
"

COLUMNS=`seq -s ',' ${COLUMN_START} ${COLUMN_END}`

FIRST_FILE=`echo ${BASE_FILES} | cut -d ' ' -f1 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`

echo "Cut 1,2,3,${COLUMNS} lines of ${BASE_FILES}."
if [ ! -f input/${EX_DIR}/${FIRST_FILE} ]
then
    mkdir -p input/${EX_DIR}

    for FILE in ${BASE_FILES}
    do
        OUTFILE=`echo ${FILE} | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
        echo "Output file: input/${EX_DIR}/${OUTFILE}"

        cut -f1,2,3,${COLUMNS} input/Example/${FILE} > input/${EX_DIR}/${OUTFILE}
    done
fi

GERMLINE_BAF=`echo ${BASE_FILES} | cut -d ' ' -f1 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
TUMOR_BAF=`echo ${BASE_FILES} | cut -d ' ' -f2 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
GERMLINE_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f3 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
TUMOR_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f4 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`

echo "########################################"
echo "Tumor LogR file    : ${TUMOR_LOGR}"
echo "Tumor BAF file     : ${TUMOR_BAF}"
echo "Germline LogR file : ${GERMLINE_LOGR}"
echo "Germline BAF file  : ${GERMLINE_LOGR}"
echo "Output Direcotry   : ${OUTPUT_PREFIX}"
echo ""
echo "Type 'true' for R debugging, or 'false'"
read DEBUG

if ${DEBUG}
then
    ${R_BIN}
else
    ${R_BIN} -q --vanilla --args \
            ${DATA_TYPE} \
            ${CHR_LIST} \
            ${SNP6_OPTION} \
            ${OUTPUT_PREFIX} \
            ${SAMPLE_NAME} \
            ${TUMOR_LOGR} \
            ${TUMOR_BAF} \
            ${GERMLINE_LOGR} \
            ${GERMLINE_BAF} \
        < ${ASCAT_SRC}
fi

