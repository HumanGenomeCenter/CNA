ACNE
====

This is a simple set of pipeline scripts for 
    aroma-project: ACNE: Allele-specific copy numbers using non-negative matrix factorization.
    (http://www.aroma-project.org/vignettes/ACNE)

1) Data structure  
Download CNA-master.zip from GitHub and you will find CNA-master/ACNE directory.

a) Scripts including

    ACNE.R
    ACNE.sh
    run_ACNE.pl
are found at CNA-master/ACNE/

b) Create a directory 'rawData' at CNA-master/ACNE and place input data (*.CEL files) to analyze.

c) Copy annotationData to CNA-master/ACNE/annotationData like the following data structure.

    CNA-master
        |-- README.md
        |-- ASCAT
        `-- ACNE
            |-- ACNE.R
            |-- ACNE.sh
            |-- annotationData
            |   `-- chipTypes
            |       |-- GenomeWideSNP_6
            |       |   |-- GenomeWideSNP_6.birdseed.models
            |       |   |-- GenomeWideSNP_6.birdseed-v2.models
            |       |   |-- GenomeWideSNP_6.brlmm-p.models
            |       |   |-- GenomeWideSNP_6.cdf
            |       |   |-- GenomeWideSNP_6.chrXprobes
            |       |   |-- GenomeWideSNP_6.chrYprobes
            |       |   |-- GenomeWideSNP_6.cif
            |       |   |-- GenomeWideSNP_6,Full.cdf
            |       |   |-- GenomeWideSNP_6,Full,monocell.CDF
            |       |   |-- GenomeWideSNP_6,Full,na31,hg19,HB20110328.ufl
            |       |   |-- GenomeWideSNP_6,Full,na31,hg19,HB20110328.ugp
            |       |   |-- GenomeWideSNP_6.Full.specialSNPs
            |       |   |-- GenomeWideSNP_6.grc
            |       |   |-- GenomeWideSNP_6,HB20080710.acs
            |       |   |-- GenomeWideSNP_6.psi
            |       |   |-- GenomeWideSNP_6.r2.qca
            |       |   |-- GenomeWideSNP_6.r2.qcc
            |       |   |-- GenomeWideSNP_6.SMD
            |       |   `-- GenomeWideSNP_6.specialSNPs
            |       |-- Mapping250K_Nsp
            |       |   |-- Mapping250K_Nsp.cdf
            |       |   |-- Mapping250K_Nsp,HB20080710.acs.gz
            |       |   |-- Mapping250K_Nsp.na31.annot.csv
            |       |   |-- Mapping250K_Nsp,na31,HB20101007.ufl
            |       |   `-- Mapping250K_Nsp,na31,HB20101007.ugp
            |       `-- Mapping250K_Sty
            |           |-- Mapping250K_Sty.cdf
            |           |-- Mapping250K_Sty,HB20080710.acs
            |           |-- Mapping250K_Sty,monocell.CDF
            |           |-- Mapping250K_Sty.na31.annot.csv
            |           |-- Mapping250K_Sty,na31,HB20101007.ufl
            |           |-- Mapping250K_Sty,na31,HB20101007.ugp
            |           `-- Mapping250K_Sty.probeInfo.tab
            |-- rawData
            |   `-- ${SAMPLE_NAME}
            |       `-- ${CHIP}
            |           `-- *.CEL
            |
            |-- README.md
            `-- run_ACNE.pl

2) Perl script  
Perl script 'run_ACNE.pl' uses the following modules. Please install.

    DateTime
    Time::HiRes
    Pod::Usage
    Getopt::Long
    Data::Dumper
    Cwd
    File::Basename
    File::Copy

3) Edit the following variables in ACNE.sh script.

    CHIP='GenomeWideSNP_6'
    SAMPLE_NAME='Test'
    OUTPUT_DIR='output'

With the above example, ACNE.R reads data from CNA-master/ACNE/rawData/Test/*.CEL files.  
GenomeWideSNP_6 is goint to be used as a chip data for analysis.  
A merged output file 'All.tab' is going to be created at CNA-master/ACNE/output/Test/GenomeWideSNP_6 .

