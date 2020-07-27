#!/bin/tcsh

: Takes fMRI NII/AFNI and T1 files as input and perform registration
: Inputs: $1 functional Directory name
:         $2 subject name
:         $3 T1 structural directory
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

set file=$OUTFILE
set BS_file='brainstemSsLabels.v10.FSvoxelSpace.nii.gz'
set ref_file=`ls $output_dir/*_reference_*.nii`

if ( ! -f "$output_dir/bs_$OUTFILE" ) then

#convert from freesurfer space to subject space
echo mri_vol2vol --mov $3/freesurfer/$2/mri/brain.mgz --targ $3/freesurfer/$2/mri/rawavg.mgz --regheader --o  $output_dir/$BS_file --no-save-reg
mri_vol2vol --mov $3/freesurfer/$2/mri/brainstemSsLabels.v10.FSvoxelSpace.mgz  --targ $3/freesurfer/$2/mri/rawavg.mgz --regheader --o  $output_dir/$BS_file --no-save-reg


#convert to 1x1x1 bs
mri_convert -vs 1 1 1 $output_dir/$BS_file $output_dir/res_$BS_file

#apply registration to move brainstem labels to functional space
flirt -in $output_dir/res_$BS_file -ref $ref_file  -applyxfm -init $output_dir/struct2func.mat -out $output_dir/bsInfunc.nii.gz
	if ( "$?" == "1" ) then
		echo "[Error] epi_reg failed with error"
		exit 1
	endif
#segment out functional brainstem area
3dcalc -b $output_dir/bsInfunc.nii.gz -a $output_dir/$OUTFILE -expr 'a*bool(b)' -prefix $output_dir/bs_$OUTFILE

set OUTFILE=bs_$OUTFILE

else
	echo "[Debug] brainstem segmentation is already performed"
endif

echo $OUTFILE
