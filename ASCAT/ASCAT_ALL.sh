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
# Input file setup
#    1. Germline_BAF.txt
#    2. Tumor_BAF.txt
#    3. Germline_LogR.txt
#    4. Tumor_LogR.txt
SAMPLE_DIR=Example
BASE_FILES="
    BAFn.txt
    BAFt.txt
    LogRn.txt
    LogRt.txt
"

#
# R options
#
DATA_TYPE='matched_data' # matched_data for Tumor and Germline set,
                         # unmatched_data for one sample
CHR_LIST='1:22'          # Chromosomes to analyze
                         # Example: '1:22,X,Y', '1:22', '1:24'
SNP6_OPTION='SNP6'       # SNP6 option. # Either 'SNP6' or 'OTHER'

######################################################################

source SGE.sh
R_BIN=/usr/local/package/r/3.0.2_icc_mkl/bin/R 
#R_BIN=/usr/local/package/r/2.15.3_icc_mkl/bin/R 
ASCAT_SRC=script/ASCAT.R


FIRST_FILE=`echo ${BASE_FILES} | cut -d ' ' -f1`
COLUMN_START=4
COLUMN_END=`head -1 input/${SAMPLE_DIR}/${FIRST_FILE} | wc -w`
OUTPUT_PREFIX=${SAMPLE_DIR}

######################################################################
#
#
COLUMNS=`seq ${COLUMN_START} ${COLUMN_END}`

for COLUMN in ${COLUMNS}
do
    CMD=
    echo "Cut 1,2,3,${COLUMN} lines of ${BASE_FILES}."

    for FILE in ${BASE_FILES}
    do
        OUTFILE=`echo ${FILE} | sed "s/\.txt/_${COLUMN}.txt/"`
        if [ ! -f input/${SAMPLE_DIR}/${OUTFILE} ]
        then
            echo "Output file: input/${SAMPLE_DIR}/${OUTFILE}"

            CMD="$CMD
                 cut -f1,2,3,${COLUMN} input/${SAMPLE_DIR}/${FILE} > input/${SAMPLE_DIR}/${OUTFILE}"

        fi
    done

    GERMLINE_BAF=`echo ${BASE_FILES} | cut -d ' ' -f1 | sed "s/\.txt/_${COLUMN}.txt/"`
    TUMOR_BAF=`echo ${BASE_FILES} | cut -d ' ' -f2 | sed "s/\.txt/_${COLUMN}.txt/"`
    GERMLINE_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f3 | sed "s/\.txt/_${COLUMN}.txt/"`
    TUMOR_LOGR=`echo ${BASE_FILES} | cut -d ' ' -f4 | sed "s/\.txt/_${COLUMN}.txt/"`

    if ${DEBUG}
    then
        ${R_BIN}
    else
        CMD="${CMD}
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
            < ${ASCAT_SRC}"
        HPC_run ASCAT "${CMD}" '4G' 'run'
    fi

done

