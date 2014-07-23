#!/bin/bash
#set -xv

SJOB="-l sjob"
LJOB="-l ljob"
LLJOB="-l lljob"

function HPC_run()
{
    _FUNCTION=$1
    _COMMAND=$2
    _MEMORY=$3
    _TEST=$4
    _QSUB_PARAMS="$5 $6 $7 $8 $9 ${10}"

    _DATETIME=`date +%Y%m%d%H%M%N`

    _JOB_ID=`date +%N`

    if [ ! -d ./tmp ]
    then
        mkdir ./tmp
    fi

    if [ ! -d ./log ]
    then
        mkdir ./log
    fi

    _CMD=./tmp/${_FUNCTION}"_"$_DATETIME".sh"

    if [ "$_TEST" == "local" ]
    then
        echo "$_COMMAND"
        eval "$_COMMAND"
    else
        cat >> $_CMD <<\_CMD1
#!/bin/bash
#
#$ -S /bin/bash # set shell in UGE
#$ -cwd         # execute at the submitted dir
pwd             # print current working directory
hostname        # print hostname
date            # print date
echo arg1=$1    # print 1st argument of shell script
date            # print date

_CMD1

        echo "$_COMMAND" >> $_CMD

        chmod +x $_CMD

        _MEM_REQ=`echo $_MEMORY | sed -e "s/G//"`
        _RUN_CMD="qsub $_QSUB_PARAMS -l s_vmem=$_MEMORY,mem_req=$_MEM_REQ -o ./log -e ./log $_CMD"
        echo $_RUN_CMD
        if [ "$_TEST" == "run" ]
        then
            $_RUN_CMD
        fi
    fi
}

