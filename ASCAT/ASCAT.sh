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

######################################################################
#
# Assumed input directory
#
# input/<sample name>/<file name>
#
# Input file setup for 'matched_data' in DATA_TYPE.
#    1. Tumor_BAF.txt
#    2. Tumor_LogR.txt
#    3. Germline_BAF.txt
#    4. Germline_LogR.txt
#
# Input file setup for 'unmatched_data' in DATA_TYPE.
#    1. Tumor_BAF.txt
#    2. Tumor_LogR.txt
#
SAMPLE_DIR=Example
BASE_FILES="
    BAFt.txt
    LogRt.txt
"
FILE_COUNT=`echo ${BASE_FILES} | wc -w`
if [ "${FILE_COUNT}" == "2" ]
then
    #
    # platform
    # "Affy100k"
    # "Affy250k_sty"
    # "Affy250k_nsp"
    # "Affy500k"
    # "AffySNP6"
    # "AffyOncoScan"
    # "Illumina109k"
    # "IlluminaCytoSNP"
    # "Illumina610k"
    # "Illumina660k"
    # "Illumina700k"
    # "Illumina1M" 
    # "Illumina2.5M"
    PLATFORM="AffySNP6"
else
    PLATFORM=
fi

DATA_TYPE='unmatched_data' # matched_data for Tumor and Germline set,
                           # unmatched_data for one sample
CHR_LIST='1:22'            # Chromosomes to analyze
                           # Example: '1:22,X,Y', '1:22', '1:24', '1:2'
SNP6_OPTION='SNP6'         # SNP6 option. # Either 'SNP6' or 'OTHER'

#
# Columns to analyze.
# Extract data column from COLUMN_START to COLUMN_END
#
COLUMN_START=11
COLUMN_END=12

######################################################################

R_BIN=/usr/local/package/r/3.0.2_icc_mkl/bin/R 
#R_BIN=/usr/local/package/r/2.15.3_icc_mkl/bin/R 
ASCAT_SRC=script/ASCAT.R

FIRST_FILE=`echo ${BASE_FILES} | cut -d ' ' -f1`
COLUMN_NUM=`head -1 input/${SAMPLE_DIR}/${FIRST_FILE}`
EX_DIR="${SAMPLE_DIR}_${COLUMN_START}-${COLUMN_END}"

OUTPUT_PREFIX=${EX_DIR}
SAMPLE_DIR=${EX_DIR}


######################################################################
#
# If the specified input data is not available, make it.
#
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

        cut -f1,2,3,${COLUMNS} input/${SAMPLE_DIR}/${FILE} > input/${EX_DIR}/${OUTFILE}
    done
fi

TUMOR_BAF=`echo ${BASE_FILES} | cut -d ' ' -f1 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
TUMOR_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f2 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
if [ "${FILE_COUNT}" == "4" ]
then
    GERMLINE_BAF=`echo ${BASE_FILES} | cut -d ' ' -f3 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
    GERMLINE_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f4 | sed "s/\.txt/_${COLUMN_START}-${COLUMN_END}.txt/"`
fi

echo "########################################"
echo "Germline LogR file : ${GERMLINE_LOGR}"
echo "Germline BAF file  : ${GERMLINE_LOGR}"
echo "Tumor LogR file    : ${TUMOR_LOGR}"
echo "Tumor BAF file     : ${TUMOR_BAF}"
echo "Output Direcotry   : ${OUTPUT_PREFIX}"
echo ""

${R_BIN} -q --vanilla --args \
        ${DATA_TYPE} \
        ${CHR_LIST} \
        ${SNP6_OPTION} \
        ${OUTPUT_PREFIX} \
        ${SAMPLE_DIR} \
        ${TUMOR_LOGR} \
        ${TUMOR_BAF} \
        ${GERMLINE_LOGR} \
        ${GERMLINE_BAF} \
        ${PLATFORM} \
    < ${ASCAT_SRC}

