#!/bin/tcsh

: Takes fMRI NII/AFNI and T1 files as input and perform registration
: Inputs: $1 Directory name
:         $2 subject name
:         $3 T1 structural file
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing registraion using epi_reg ..."

if ($#argv != 3) then
    echo "[Error] Insufficient number of input arguments. Expected 3 got $#argv"
    exit 1
endif

: check if file exists
if ( ! -d "$1" ) then
    echo "[Error] Parent directory $1 not found "
    exit 1
endif

if ( ! -d "$1/$2" ) then
    echo "[Error] Subject directory $1/$2 not found "
    exit 1
endif

if ( ! -f "$output_dir/$OUTFILE" ) then
    echo "[Error] Input file $output_dir/$OUTFILE not found "
    exit 1
endif

if ( ! -f "$1/$2/$3" ) then
    echo "[Error] Input Structural file $1/$2/$3 not found "
    exit 1
endif

set file=$OUTFILE
set T1_file=$3

if ( ! -f "$output_dir/struct2func.mat" ) then

bet $1/$2/$T1_file $output_dir/bet_$T1_file
3dTcat -prefix $output_dir/${base}_reference_$minindex $output_dir/$file'['$minindex']'
3dAFNItoNIFTI -prefix  $output_dir/${base}_reference_$minindex   $output_dir/${base}_reference_$minindex+tlrc.BRIK

echo epi_reg --epi=$output_dir/${base}_reference_$minindex".nii"  --t1=$1/$2/$T1_file --t1brain=$output_dir/bet_$T1_file --out=$output_dir/func2struct.mat
epi_reg --epi=$output_dir/${base}_reference_$minindex".nii"  --t1=$1/$2/$T1_file --t1brain=$output_dir/bet_$T1_file --out=$output_dir/func2struct
	if ( "$?" == "1" ) then
		echo "[Error] epi_reg failed with error"
		exit 1
	endif
convert_xfm -omat $output_dir/struct2func.mat -inverse $output_dir/func2struct.mat


else
	echo "[Debug] co-registration is already performed"
endif

echo $OUTFILE
