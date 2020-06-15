#!/bin/tcsh

: Takes T1 NII/AFNI filename as input and performs resampling to size 1x1x1
: Inputs: $1 T1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Resampling T1  data to LAS orientation ..."

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
    echo "[Error] Input file $output_dir/$OUTFILE not found "
    exit 1
endif

set file=$OUTFILE


set outfilename=`ls $output_dir/$base"_resampled.nii.gz"`

if ( ! -f "$outfilename" ) then
	echo mri_convert -vs 1 1 1 $output_dir/$file  $output_dir/$base"_resampled.nii.gz"
	mri_convert -vs 1 1 1 $output_dir/$file  $output_dir/$base"_resampled.nii.gz"
	if ( "$?" == "1" ) then
		echo "[Error] mri_convert failed with error"
		exit 1
	endif
else
	echo "[Debug]  fMRI data is already resampled [$OUTFILE]"
endif

set OUTFILE=`ls $output_dir/$base"_resampled.nii.gz" | xargs -n 1 basename`
echo $OUTFILE
