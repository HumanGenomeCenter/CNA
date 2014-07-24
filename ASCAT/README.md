ASCAT
=====

This is a simple set of pipline scripts for ASCAT.  
ASCAT is a tool for accurate dissection of genome-wide allele-specific copy number in tumors.  
(http://heim.ifi.uio.no/bioinf/Projects/ASCAT/)

1)  Directory Structure

If you download CNA-master.zip from GitHub and extract it, 

    CNA-master
        |-- README.md
        |-- ACNE
        `-- ASCAT
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


    CNA-master
        |-- README.md
        |-- ACNE
        `-- ASCAT
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

You need to set arguments in ASCAT.sh or ASCAT_ALL.sh.  

There are 9 arguments for ASCAT.R.

    data type
        Either 'matched_data' or 'unmatched_data'. 'matched_data' indicates that there are 2 sets of data. BAF and LogR data for germline and tumor. 'unmatched_data' indicates that there is only 1 set of BAF and LogR data.
    chromosome list
        Specify the list of chromosomes to analyze. Examples are '1:22', '1,2,3', '1:22,X,Y'.
    SNP6 option
        Either 'SNP6', or 'OTHER'
    output file prefix for *.RData, *.A.seg, *.B.seg, *.total.seg, *.ploidy.txt, *.acfrac.txt
    sample name
    Tumor LogR file name
    Tumor BAF file name
    Germline LogR file name
    Germline BAF file name
    platform
        "Affy100k"
        "Affy250k_sty"
        "Affy250k_nsp"
        "Affy500k"
        "AffySNP6"
        "AffyOncoScan"
        "Illumina109k"
        "IlluminaCytoSNP"
        "Illumina610k"
        "Illumina660k"
        "Illumina700k"
        "Illumina1M" 
        "Illumina2.5M"

In ASCAT.sh or ASCAT_ALL.sh, there are the following variables, which are eventually passed to ASCAT.R.

    SAMPLE_DIR
        Input data directory in ASCAT/input/
        Output data directory in ASCAT/output/
    BASE_FILES
        Input data file name in the following order
            Tumor BAF file
            Tumor LogR file
            Germline BAF file
            Germline LogR file
    PLATFORM
        Passed to platform in ASCAT.R. This is only for 'unmatched_data'.
    CHR_LIST
        Passed to chromosome list in ASCAT.R
    SNP6_OPTION
        Passed to SNP6 optio in ASCAT.R

In ASCAT.sh, you need to specify start column and end column in data file to analyze. ASCAT.sh cuts only the columns and pass them to ASCAT.R.

4)  Output data files

After running ASCAT.sh, output files are created at CNA-master/output .

    CNA-master
        |-- README.md
        |-- ACNE
        `-- ASCAT
            |-- script
            |   `-- ASCAT2.1
            |       |-- ascat.R
            |       |-- aspcf.R
            |       `-- predictGG.R
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
