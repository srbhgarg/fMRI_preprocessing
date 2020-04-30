#!/bin/tcsh
: Takes AFNI processed file as input and converts it to a NII file. 
: Inputs: $1 Directory name
:         $2 subject name
: Output: Output  file name will be set in OUTFILE
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC

echo "Input filename Step ........"

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
    echo "[Error] Input filename $OUTFILE/$OUTFILE not found "
    exit 1
endif


3dAFNItoNIFTI -prefix $output_dir/fMRI_preprocessed  $output_dir/$OUTFILE
if ( "$?" == "1" ) then
	echo "[Error]  3dAFNItoNIFTI  failed with error"
	exit 1
endif
set OUTFILE=fMRI_preprocessed.nii

echo $OUTFILE
echo "------------------------- END -----------------------"
