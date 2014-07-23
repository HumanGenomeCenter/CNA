#
# ASCAT R script
#

######################################################################
#
# Fetch arguments
#
args         <- commandArgs(TRUE)
data_type    <- args[ 1 ]   # Either 'matched_data' or 'unmatched_data'
chr_list     <- args[ 2 ]   # Example: '1:22,X,Y', '1:22', '1:24'
SNP6_option  <- args[ 3 ]   # Either 'SNP6' or 'OTHER'

outfile      <- args[ 4 ]
sample_name  <- args[ 5 ]

logrt        <- args[ 6 ]
baft         <- args[ 7 ]

if ( data_type == 'matched_data' )
{
    logrn        <- args[ 8 ]
    bafn         <- args[ 9 ]
    debug_on     <- args[ 10 ]
} else {
    debug_on     <- args[ 8 ]
}

if ( ! is.na( debug_on ) )
{
# For testing.
    data_type    <- 'matched_data'
    chr_list     <- '1'
    SNP6_option  <- 'SNP6'

    outfile      <- 'Example_11-12'
    sample_name  <- 'Example_11-12'

    logrt        <- 'LogRt_11-12.txt'
    baft         <- 'BAFt_11-12.txt'
    logrn        <- 'LogRn_11-12.txt'
    bafn         <- 'BAFn_11-12.txt'
#
}

data_type
chr_list
SNP6_option
outfile
sample_name
logrt
baft
logrn
bafn

#
# Make data directories
#
cwd          <- getwd()
inputDir     <- paste( cwd, 'input', sample_name, sep='/' )
outputDir    <- paste( cwd, "output", sample_name, sep='/' )
ASCAT2.1_Dir <- paste( cwd, "script/ASCAT2.1", sep='/' )

######################################################################
#
# Subroutines
#
preprocessSNP6LogR<-function(x){
  x<-log2(x)
  tmp<-mean(as.numeric(unlist(x)))
  x<- x-tmp
  tmp<-quantile(abs(as.matrix(x)), 0.999)
  x[x> tmp]<- tmp
  x[x< -tmp]<- -tmp
  return(x)
}

getBAFseg<-function(x){
  chr0<-as.numeric(x$"SNPpos"[,1])
  pos0<-as.numeric(x$"SNPpos"[,2])
  smp<-x$"samples"
  names(chr0)<-rownames(x$"SNPpos")
  names(pos0)<-rownames(x$"SNPpos")
  S<-NULL
  for(i in 1:length(smp)){
   v<-x$"Tumor_BAF_segmented"[[i]][,1]  
   names(v)<-rownames(x$"Tumor_BAF_segmented"[[i]]) 
   v<-v[names(sort(chr0[names(sort(pos0[names(v)]))]))]
   chr<-chr0[names(v)]
   pos<-pos0[names(v)]
   seen<-NA
   p<-NULL
   pc<-0
   for(j in 1:length(v)){
     if(is.na(seen)){
       seen<-v[j]
       p<-pos[j]
       pc <- 1
     }else if(seen != v[j] | chr[j-1] != chr[j]){
        S<-rbind(S, c(smp[i], chr[j-1] ,p,pos[j-1], pc, v[j-1]))
        p<-pos[j]
        seen<-v[j]
        c<-chr[j]
        pc <- 1
     }else{
       pc <- pc + 1
     }
   }
   S<-rbind(S, c(smp[i], chr[length(v)] ,p,pos[length(v)], pc, v[length(v)]))
  }
  colnames(S)<-c("ID", "chrom", "loc.start", "loc.end", "num.mark", "seg.mean")
  return(S)
}

getLogRseg<-function(x){
  chr0<-as.numeric(x$"SNPpos"[,1])
  pos0<-as.numeric(x$"SNPpos"[,2])
  smp<-x$"samples"
  names(chr0)<-rownames(x$"SNPpos")
  names(pos0)<-rownames(x$"SNPpos")
  S<-NULL
		   for(i in 1:length(smp)){
    v<-x$"Tumor_LogR_segmented"[,i]  
    v<-v[names(sort(chr0[names(sort(pos0[names(v)]))]))]
    chr<-chr0[names(v)]
    pos<-pos0[names(v)]
    seen<-NA
    p<-NULL
    pc<-0
    for(j in 1:length(v)){
      if(is.na(seen)){
        seen<-v[j]
        p<-pos[j]
        pc <- 1
      }else if(seen != v[j] | chr[j-1] != chr[j]){
        S<-rbind(S, c(smp[i], chr[j-1] ,p,pos[j-1], pc, v[j-1]))
        p<-pos[j]
        seen<-v[j]
        c<-chr[j]
        pc <- 1
      }else{
        pc <- pc + 1
      }
    }
    S<-rbind(S, c(smp[i], chr[length(v)] ,p,pos[length(v)], pc, v[length(v)]))
  }
  colnames(S)<-c("ID", "chrom", "loc.start", "loc.end", "num.mark", "seg.mean")
  return(S)
}


organize.ascat.segments <- function(ascat.output, markers) {
  samp.names <- colnames(ascat.output$nA)
  failed.names <- ascat.output$failedarrays
  if (length(failed.names) >= 1) {
    failed.locations <- which(is.na(ascat.output$segments))
    new.samp.names <- 1:length(ascat.output$segments)
    new.samp.names[-c(failed.locations)] <- samp.names
    new.samp.names[failed.locations] <- failed.names
    samp.names <- new.samp.names
}
  out.seg <- matrix(0, 0, ncol = 7)
  colnames(out.seg) <- c("SampleID", "Chr", "Start", "End",
                         "nProbes", "nA", "nB")
  if (length(ascat.output$segments) != length(samp.names)) {
    return(NULL)
}
  for (i in 1:length(ascat.output$segments)) {
    sample.segs <- ascat.output$segments[[i]]
	if (class(sample.segs) != "matrix") {
      next
    }
    if (class(sample.segs) == "matrix") {
      out.seg.tmp <- matrix(0, 0, ncol = 7)
      err<-FALSE
      for (j in 1:nrow(sample.segs)) {
        tmp <- markers[sample.segs[j, 1]:sample.segs[j,2], ]
##	if (!all(tmp[, 1] == tmp[1, 1])) {
##        err<-TRUE
##	  break
##      }
        chr <- as.character(tmp[1, 1])
        seg.start <- as.character(tmp[1, 2])
        seg.end <- as.character(tmp[nrow(tmp), 2])
        nProbes <- nrow(tmp)
        out.seg.tmp  <- rbind(out.seg.tmp , c(samp.names[i], chr,
                                              seg.start, seg.end, nProbes, sample.segs[j,3:4]))
  }
      gc()
	  if(!err){
        out.seg  <- rbind(out.seg,out.seg.tmp)
      }
    }
  }
  #out.seg[out.seg[, 2] == "X", 2] <- 23
  out.seg <- as.data.frame(out.seg)
  out.seg[, 2:7] <- apply(out.seg[, 2:7], 2, function(x) {
    as.numeric(as.character(x))
			  })
  out.seg[, 1] <- as.character(out.seg[, 1])
  return(out.seg)
}

######################################################################
#
# Main
#

#
# Load 'ascat.R'
#
setwd( ASCAT2.1_Dir )
source( "ascat.R" )

#
# Create output directory
#
dir.create( paste( cwd, "output", sep='/' ) )
dir.create( outputDir )

#
# Load input files
#
setwd( inputDir )

# Needs to take care of X and Y
X <- length( grep( "X", chr_list ) )
Y <- length( grep( "Y", chr_list ) )
if ( X )
{
    chr_list <- sub( ",?X", "", chr_list )
}
if ( Y )
{
    chr_list <- sub( ",?Y", "", chr_list )
}

chr_list_tmp <- eval( parse( text=paste( 'c(', chr_list, ')' ) ) )
if ( X )
{
    ch_list_tmp <- c( chr_list_tmp, 'X' )
}
if ( Y )
{
    ch_list_tmp <- c( chr_list_tmp, 'Y' )
}

# Load input files
if ( data_type == 'matched_data' )
{
    ascat.bc = ascat.loadData(  logrt,
                                baft,
                                logrn,
                                bafn,
                                chrs = chr_list_tmp )
} else {
    ascat.bc = ascat.loadData(  logrt,
                                baft,
                                chrs = chr_list_tmp )
    setwd( ASCAT2.1_Dir )
    source( "predictGG.R" )
}

#
# Preprocess for SNP6
#
if ( SNP6_option == 'SNP6' )
{
    tmp<-(ascat.bc$Germline_LogR)
    ascat.bc$Germline_LogR <-preprocessSNP6LogR(tmp)
    tmp<-(ascat.bc$Tumor_LogR)
    ascat.bc$Tumor_LogR <-preprocessSNP6LogR(tmp)
}

#
# plotRawData
#
setwd( outputDir )
ascat.plotRawData(ascat.bc)

#
# aspcf.R
#
setwd( ASCAT2.1_Dir )
ascat.bc = ascat.aspcf(ascat.bc)

#
# plotSegmentedData
#
setwd( outputDir )
ascat.plotSegmentedData( ascat.bc )

#
# runAscat
#
ascat.output = ascat.runAscat( ascat.bc )

save.image( file = paste( outfile, ".RData", sep = "" ) )

#
# Segmented data
#
ascat.segments <- organize.ascat.segments( ascat.output, ascat.bc$SNPpos )

segA         <- ascat.segments[,1:6]
segB         <- ascat.segments[,1:7]
segTotal     <- segA
segTotal[,6] <- segTotal[,6] + segB[,6]

tmp                     <- c("ID", "chrom", "loc.start", "loc.end", "num.mark", "seg.mean")
colnames( segA )        <- tmp
colnames( segB )        <- tmp
colnames( segTotal )    <- tmp

samp                        <- colnames(ascat.output$nA)
aberrantcellfraction        <- ascat.output$aberrantcellfraction
ploidy                      <- ascat.output$ploidy
names(aberrantcellfraction) <- samp
names(ploidy)               <- samp

tmp<-unique(segA[,1])
aberrantcellfraction<-aberrantcellfraction[tmp]
ploidy<-ploidy[tmp]

#
# Write tables
#
write.table( segA,
             paste(outfile, ".A.seg", sep=""),
             row.names = FALSE,
             quote = FALSE,
             sep = "\t" )
write.table( segB,
             paste(outfile, ".B.seg", sep = ""),
             row.names = FALSE,
             quote = FALSE,
             sep = "\t" )
write.table( segTotal,
             paste(outfile, ".total.seg", sep=""),
             row.names =FALSE,
             quote = FALSE,
             sep = "\t" )

write.table( as.matrix(ploidy),
             paste(outfile, ".ploidy.txt", sep=""),
             row.names=TRUE,
             col.names = FALSE,
             quote=FALSE,
             sep="\t" )

write.table( as.matrix(aberrantcellfraction),
             paste(outfile, ".acfrac.txt", sep=""),
             row.names = TRUE,
             col.names = FALSE,
             quote=FALSE,
             sep="\t" )

