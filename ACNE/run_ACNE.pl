#! /usr/bin/perl
#
# run_ACNE.pl
#
#

#
# pragma
#
use warnings;
use diagnostics;
use strict;
use 5.010; # To use some new features of Perl 5.010


#
# CPAN modules
#
use DateTime;
use Time::HiRes;
use Pod::Usage;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);
use Data::Dumper;
use Cwd;
use File::Basename;
use File::Copy;

#
# Private modules
#

#
# main
#
package main;

#
# Argument check
#
our $str_my_name = $0;
$str_my_name =~ s/\S+\/(\S+)$/$1/;


our $VERSION =           '$Revision: 1 $';
our $LAST_CHANGED_DATE = '$LastChangedDate: 2013-05-14 $';

our ( $str_verbose,
      $str_help,
      $str_chip,
      $str_input_dir,
      $str_output_dir,
      $str_file_max,
      $str_sample_dir,
      $str_r_bin,
      $str_r_src,
      );

ProcessArguments( \@ARGV );

my $SGE_header = <<'SGE_HEADER';
#!/bin/bash
#
# ACNE 
#
#$ -S /bin/bash # set shell in UGE
#$ -cwd         # execute at the submitted dir
#$ -e log
#$ -o log
pwd             # print current working directory
hostname        # print hostname
date            # print date
echo arg1=$1    # print 1st argument of shell script
sleep 20        # sleep 20 seconds

SGE_HEADER

#
# Main 
#

#
# Print header
#
my $obj_date;
if ( 1 )
{
    $obj_date = DateTime->now( time_zone => 'local' );
    print  '#' x 70 ."\n";
    printf  "%s started at %4d.%02d.%02d.%02d:%02d\n",
            $str_my_name,
            $obj_date->year,
            $obj_date->month,
            $obj_date->day,
            $obj_date->hour,
            $obj_date->minute;
}


######################################################################
#
# Start new code here
#
{
    #
    # Make sure that data structure for aroma-project
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

    # 
    # Make sure that annotationData directory has the right chip data. 
    # 
    my $annoDir = "annotationData/chipTypes/$str_chip";
    if ( ! -d  $annoDir )
    {
        die( " Chip data for $str_chip does not exist." );
    }
    my @input_files = glob( $annoDir . '/*.*' );
    if ( scalar( @input_files ) == 0 )
    {
        die( "$annoDir does not have any file." );
    }

    #
    # Make sure that teh CEL data files
    #
    my $rawData = "rawData/$str_sample_dir/$str_chip";
    if ( ! -d  $rawData)
    {
        die( "$rawData does not exist." );
    }
    @input_files = glob( $rawData . '/*.*' );
    if ( scalar( @input_files ) == 0 )
    {
        die( "$rawData does not have any file." );
    }
    printf "The number of CEL files is %d.\n", scalar @input_files;

    #
    # Make log direcotry for qsub
    #
    mkdir 'log';

    #
    # output data directory
    #
    my $outputDataDir = $str_output_dir . '/' . $str_sample_dir .  '/' . $str_chip;
    print "Data is output in $outputDataDir.\n";


    my $id = $obj_date->second .
             $obj_date->minute .
             $obj_date->hour .
             $obj_date->month . 
             $obj_date->year;

    #
    # Submit jobs
    #
    print "Start running ACNE.R on the files in $rawData.\n";
    my $cmd_name = "j$id.sh";
    {
        my $R_cmd = "$str_r_bin -q --vanilla --args $str_chip $str_sample_dir $str_output_dir < $str_r_src \n";

        my $filehandle;
        open( $filehandle, '> ' . $cmd_name )
            or die "$cmd_name cannot be opened.";
        print $filehandle $SGE_header;
        print $filehandle $R_cmd;
        close( $filehandle );
    }

    while( 
            system( "qsub -l s_vmem=8G,mem_req=8 $cmd_name" ) != 0
         )
    {
        sleep(10);
    }

    move( $cmd_name, 'log' );

    print "Wait for job:$cmd_name to finish.\n";
    Wait_for_SGE_job_to_finish( $cmd_name );

    print "ACNE analysis finished!\n";

}

#
# End
#
######################################################################

######################################################################
#
# Subroutine
#

sub ProcessArguments
{
    my $list_command_ref = shift;

    GetOptions(
                'verbose|v'       =>\$str_verbose,
                'help|h'          =>\$str_help,
                'chip|c=s'        =>\$str_chip,
                'output_dir|o=s'  =>\$str_output_dir,
                'sample_dir|a=s'  =>\$str_sample_dir,
                'r_binary|b=s'    =>\$str_r_bin,
                'r_src|s=s'       =>\$str_r_src,
    );

    if ( defined $str_help )
    {
        pod2usage( -verbose=>1, -exitval=>1, -output=>\*STDOUT );
    }
    elsif ( ! defined $str_sample_dir || ! defined $str_chip || ! defined $str_output_dir )
    {
        pod2usage( -verbose=>1, -exitval=>1, -output=>\*STDOUT );
    }
}

sub Wait_for_SGE_job_to_finish
{
    my $script_name = shift;

    $script_name = substr( $script_name, 0, 10 );

    while( 1 )
    {
       while(system("qstat > /dev/null") != 0)
       {
           sleep(10);
       }
       my $out = `qstat | grep $script_name | wc -l`;

       if( $out == 0 )
       {
           print "\n";
           print "Job:$script_name finished.";
           return;
       }
       else
       {
           sleep(10);
           print ".";
       }
    }
}

######################################################################

1;

=head1 NAME

setupACNE.pl [arguments]
    
=head1 SYNOPSIS

setupACNE.pl [arguments]


    Optional arguments:
        -h, --help                      print help message
        -v, --verbose                   use verbose output
        -c, --chip                      chip type
        -o, --output_dir                output directory
        -a, --sample_dir                sample directory
        -b, --r_binary                  R binary (absolute path)
        -s, --r_src                     R source file name: 'ACNE.R'

=head1 OPTIONS

=over 8

=item B<--help>

print a brief usage message and detailed explanation of options.

=item B<--man>

print the complete manual of the program.

=item B<--verbose>

use verbose output.

=back

=head 1 DESCRIPTION

B<This program> will read the given input file(s) and do something useful with the contents thereof.
=cut

__END__
