#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and perform slice timing correction
: Inputs: $1 Directory name
:         $2 subject name
:         $3 correction type: --odd for interleave
:         $4 TR 
:         input file is obtained from OUTFILE environment variable
: Output: Output nii file 
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing slice timing correction ..."

if ($#argv != 4) then
    echo "[Error] Insufficient number of input arguments. Expected 4 got $#argv"
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
set niifile=`echo $file| cut -d'.' -f1`
set ext=`echo $file| cut -d'.' -f2`
set OUTFILE="$base"_stc.nii.gz


if ( ! -f "$output_dir/$OUTFILE" ) then

	if( $ext == "BRIK" || $ext == "HEAD" ) then
		3dAFNItoNIFTI -prefix $output_dir/$niifile  $output_dir/$file
		slicetimer.fsl -i $output_dir/$niifile".nii" -o  $output_dir/$OUTFILE -r $4 $3
	else
		slicetimer.fsl -i $output_dir/$file -o  $output_dir/$OUTFILE -r $4 $3
	endif
	if ( "$?" == "1" ) then
		echo "[Error] 3dresample failed with error"
		exit 1
	endif
else
	echo "[Debug]  slice timing correction is already performed"
endif

echo $OUTFILE
