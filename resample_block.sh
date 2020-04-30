#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and performs resampling in LAS orientation
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Resampling fMRI  data to LAS orientation ..."

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

set OUTFILE="$base"_resampled+tlrc.BRIK


if ( ! -f "$output_dir/$OUTFILE" ) then
	echo 3dresample -orient asl -rmode NN -prefix $output_dir/$base"_resampled" -input  $output_dir/$file  
	3dresample -orient asl -rmode NN -prefix $output_dir/$base"_resampled" -input  $output_dir/$file  
	if ( "$?" == "1" ) then
		echo "[Error] 3dresample failed with error"
		exit 1
	endif
else
	echo "[Debug]  fMRI data is already resampled [$OUTFILE]"
endif

echo $OUTFILE
