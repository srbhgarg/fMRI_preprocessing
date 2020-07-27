#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and performs grand mean scaling to 10000 using FSL
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE  variable
: Output: Output afni file name
:
: Author: Saurabh
: April 23 2020, PPRC @ UBC




echo "[Main] Grand Mean Scaling fMRI  data ..."

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

set outfilename=`ls $output_dir/*scaled*.nii.gz`


if ( ! -f "$outfilename" ) then

: compute mask
bet2 $output_dir/$OUTFILE $output_dir/bet_$OUTFILE -m -n
set bet_file=`ls $output_dir/bet*motion_corrected_mask*`



set meanintensity=`fslstats $output_dir/$file -k $bet_file -p 50`
set inscalefactor=`python -c "print((10000/$meanintensity))"`
echo "Grand means scaling factor: " $inscalefactor
fslmaths  $output_dir/$file  -mul $inscalefactor  $output_dir/${base}_scaled.nii.gz
if ( "$?" == "1" ) then
	echo "[Error] Grand mean scaling failed with error"
	exit 1
endif
else
	echo "[Debug]  fMRI data is already been mean scaled"
endif

set OUTFILE=`ls $output_dir/${base}_scaled.nii.gz | xargs -n 1 basename`
echo $OUTFILE
