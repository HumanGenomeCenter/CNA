ASCAT
=====

This is a simple set of pipline scripts for ASCAT.  
ASCAT is a tool for accurate dissection of genome-wide allele-specific copy number in tumors.  
(http://heim.ifi.uio.no/bioinf/Projects/ASCAT/)

1)  Directory Structure

ASCAT.sh needs to be placed in the [Working Directory]

    [Working Directory]
        |-- ASCAT.sh
        `-- script
            |-- ASCAT2.1
            |   |-- ascat.R
            |   |-- aspcf.R
            |   `-- predictGG.R
            `-- ASCAT.R


2)  Input data files

You need to prepare 4 files.  

    Germline_BAF.txt
    Germline_LogR.txt
    Tumor_BAF.txt
    Tumor_LogR.txt


    [Working Directory]
        |-- script
        |   `-- ASCAT2.1
        `-- input
            `-- [Sample Name]
                |-- Germline_BAF.txt
                |-- Germline_LogR.txt
                |-- Tumor_BAF.txt
                `-- Tumor_LogR.txt

3)  Run ASCAT.sh

a)  Select columns to analyze from base files. 

ASCAT.sh cut a portion of data from Germline_BAF.txt, Germline_LogR.txt, Tumor_BAF.txt, and Tumor_LogR.txt.  
The first and second columns have 

b) Set arguments for ASCAT.R

There are 9 rguments for ASCAT.R.

    data type
    chromosome list
    SNP6 option
    output file prefix for *.RData, *.A.seg, *.B.seg, *.total.seg, *.ploidy.txt, *.acfrac.txt
    sample name
    Tumor LogR file name
    Tumor BAF file name
    Germline LogR file name
    Germline BAF file name


4)  Output data files

After running ASCAT.sh, output files are created at [Working Directory]/output .

    [Working Directory]
        |-- script
        |   `-- ASCAT2.1
        |-- input
        |   `-- [Sample Name]
        |       |-- Germline_BAF.txt
        |       |-- Germline_LogR.txt
        |       |-- Tumor_BAF.txt
        |       `-- Tumor_LogR.txt
        `-- output
            `-- [Sample Name]
               |-- [Sample Name].acfrac.txt
               |-- [Sample Name].A.seg
               |-- [Sample Name].B.seg
               |-- [Sample Name].ploidy.txt
               |-- [Sample Name].RData
               |-- [Sample Name].total.seg
               `-- *.png


5) Caveats

The function 'ascat.aspcf' creates cache files at script/ASCAT2.1.  
The files are something like  

    LogR_PCFed_TCGA.A6.2675.01A.02D.1717.01.txt
    BAF_PCFed_TCGA.A6.2675.01A.02D.1717.01.txt

If you are going to run ASCAT.sh with the same samples ('TCGA.A6.2675.01A.02D.1717.01') with different data set, the cache files cause error in 'ascat.aspcf'.  
You need to delete those caache files before running ASACT.sh.
