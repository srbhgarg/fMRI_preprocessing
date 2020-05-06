#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and performs smoothing
: Inputs: $1 Directory name
:         $2 subject name
:         $3 level of smoothness
:         input file is obtained from OUTFILE  variable
: Output: Output afni file name
:
: Author: Saurabh
: April 25 2020, PPRC @ UBC


echo "[Main] Smoothing fMRI  data ..."

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
    echo "[Error] Input file $1/$2/$OUTFILE not found "
    exit 1
endif

set file=$OUTFILE


set outfilename=`ls $output_dir/*smoothed*.HEAD`

if ( ! -f "$outfilename" ) then

    3dBlurToFWHM -input $output_dir/$file -prefix $output_dir/"$base"_smoothed -automask -FWHM $3 
   if ( "$?" == "1" ) then
	echo "[Error] 3dBlurToFWHM failed with error"
	exit 1
   endif
   mv 3dFWHMx* $output_dir/
else
	echo "[Debug]  fMRI data is already smoothed"
endif

set OUTFILE=`ls $output_dir/*smoothed*.HEAD | xargs -n 1 basename`
echo $OUTFILE
