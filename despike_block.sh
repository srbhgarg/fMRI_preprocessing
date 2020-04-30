#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and performs despiking
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE  variable
: Output: Output afni file name
:
: Author: Saurabh
: April 23 2020, PPRC @ UBC




echo "[Main] Despiking fMRI  data ..."

if ($#argv != 2) then
    echo "[Error] Insufficient number of input arguments. Expected 2 got $#argv"
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
    echo "[Error] Input file $1/$2/$OUTFILE not found "
    exit 1
endif

set file=$OUTFILE


set OUTFILE="$base"_despiked+tlrc.BRIK
: set environment for new despiking methof
setenv AFNI_3dDespike_NEW YES

if ( ! -f "$output_dir/$OUTFILE" ) then
echo 3dDespike -corder NT/30 -cut  3.1  5.0 -prefix $output_dir/${base}_despiked  $output_dir/$file
3dDespike -corder NT/30 -cut  3.1  5.0 -prefix $output_dir/${base}_despiked  $output_dir/$file
if ( "$?" == "1" ) then
	echo "[Error] 3dDespike failed with error"
	exit 1
endif
else
	echo "[Debug]  fMRI data is already despiked"
endif

echo $OUTFILE
