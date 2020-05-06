#!/bin/tcsh

: Takes fMRI NII/AFNI and T1 files as input and perform motion correction
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing motion correction using mcflirt ..."

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
set outfilename=`ls $output_dir/*motion_corrected.nii.gz`

if ( ! -f "$outfilename" ) then

touch $output_dir/out.pre_ss_warn.txt

echo 3dToutcount -automask -fraction -polort 5 -legendre $output_dir/$file savedto  $output_dir/outcount_rall.1D
3dToutcount -automask -fraction -polort 5 -legendre $output_dir/$file >  $output_dir/outcount_rall.1D

:  outliers at TR 0 might suggest pre-steady state TRs
if ( `1deval -a  $output_dir/outcount_rall.1D"{0}" -expr "step(a-0.4)"` ) then
        echo "** TR #0 outliers: possible pre-steady state TRs" \
            >> $output_dir/out.pre_ss_warn.txt
endif

set minima=`cat $output_dir/outcount_rall.1D | sort | head -1`
set reference=`grep -n $minima $output_dir/outcount_rall.1D| cut -d':' -f1| head -1`
:  get run number and TR index for minimum outlier volume
set minindex = `3dTstat -argmin -prefix - $output_dir/outcount_rall.1D\'`
echo minima=$minima   reference=$reference   minindex=$minindex 

	echo mcflirt -in $output_dir/$file -out $output_dir/motion_corrected -refvol $minindex -plots -stats 
	mcflirt -in $output_dir/$file -out $output_dir/motion_corrected -refvol $minindex -plots -stats 

	if ( "$?" == "1" ) then
		echo "[Error] mcflirt failed with error"
		exit 1
	endif
else
	echo "[Debug] motion correction is already performed"
endif

set OUTFILE=`ls $output_dir/*motion_corrected.nii.gz | xargs -n 1 basename`
echo $OUTFILE
