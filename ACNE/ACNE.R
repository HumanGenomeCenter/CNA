#
# ACNE R script
#
library("aroma.affymetrix");
library("ACNE");

args        <- commandArgs(TRUE)
chipType    <- args[ 1 ]
dataSet     <- args[ 2 ]
outputDir   <- args[ 3 ]

chipType
dataSet
outputDir

verbose <- Arguments$getVerbose(-10, timestamp=TRUE);

workDir <- getwd()
outDir  <- paste( workDir, outputDir, sep="/" );
dataSetDir  <- paste( outDir, dataSet, sep="/" )
chipTypeDir <- paste( dataSetDir, chipType, sep="/" )

dir.create(outDir,      showWarnings = FALSE);
dir.create(dataSetDir,  showWarnings = FALSE);
dir.create(chipTypeDir, showWarnings = FALSE);

######################################################################
#
# Setup annotation data
#
# Get CDF
#cdf <- AffymetrixCdfFile$byChipType(chipType);
cdf <- AffymetrixCdfFile$byChipType(chipType, tags="Full");

gi <- getGenomeInformation(cdf);

si <- getSnpInformation(cdf);

acs <- AromaCellSequenceFile$byChipType(getChipType(cdf, fullname=FALSE));

######################################################################
#
# Setup raw data
#
cs <- AffymetrixCelSet$byName(dataSet, cdf=cdf);

######################################################################
#
# Probe-processing as in CRMA v2
#
acc <- AllelicCrosstalkCalibration(cs, model="CRMAv2");

csC <- process(acc, verbose=verbose);

bpn <- BasePositionNormalization(csC, target="zero");

csN <- process(bpn, verbose=verbose);


######################################################################
#
# ACNE probe summarization
#
plm <-NmfSnpPlm(csN, mergeStrands=TRUE);

if (length(findUnitsTodo(plm)) > 0)
{
  # Fit CN probes quickly (~5-10s/array + some overhead)
  units <- fitCnProbes(plm, verbose=verbose)
  str(units)
  # int [1:945826] 935590 935591 935592 935593 935594 935595 ...
 
  # Fit remaining units, i.e. SNPs (~5-10min/array)
  units <- fit(plm, verbose=verbose)
  str(units)
}
 
ces <- getChipEffectSet(plm);

save.image();

######################################################################
#
# write data to tab files
#
arrayNum    <- length(ces);

probeId     <- getUnitNames(cdf);

tmp         <- names( extractDataFrame(ces, units=1, addNames=TRUE) )
arrayId     <- tmp[6:length(tmp)];

for( i in 1:arrayNum )
{
      cf    <- getFile(ces, i);
      data  <- extractTotalAndFreqB(cf);
      CT    <- data[,"total"];
      beta  <- data[,"freqB"];

      A     <- CT*(1-beta)
      B     <- CT*beta
      x     <- cbind(A,B)

      rownames(x)   <- probeId
      file          <- paste(chipTypeDir, "/", arrayId[i], ".tab", sep="")

      write( c("", colnames(x)), file,  append=F, sep="\t", ncolumns=ncol(x)+1 )
      write.table(x, file, quote=F, col.names=F, append=T, sep="\t")

}

