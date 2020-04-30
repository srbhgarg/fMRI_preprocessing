#!/bin/tcsh

: Takes fMRI NII/AFNI and T1 files as input and extract mean time course
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] extracting mean time course using 3dmaskave ..."

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

if ( ! -f "$1/freesurfer/$2/surf/SUMA/aparc.a2009s+aseg.nii.gz" ) then
    echo "[Error] Input aparc.a2009s+aseg file not found "
    exit 1
endif

set file=$OUTFILE

echo flirt -interp nearestneighbour -in $1/freesurfer/$2/surf/SUMA/aparc.a2009s+aseg.nii.gz -ref $output_dir/${base}_reference_$minindex".nii" -applyxfm -init $output_dir/struct2func.mat -out $output_dir/fMRI_aparc.a2009s+aseg.nii.gz
flirt -interp nearestneighbour -in $1/freesurfer/$2/surf/SUMA/aparc.a2009s+aseg.nii.gz -ref $output_dir/${base}_reference_$minindex".nii" -applyxfm -init $output_dir/struct2func.mat -out $output_dir/fMRI_aparc.a2009s+aseg.nii.gz

echo flirt -interp nearestneighbour -in $1/freesurfer/$2/surf/SUMA/aparc+aseg.nii.gz -ref $output_dir/${base}_reference_$minindex".nii" -applyxfm -init $output_dir/struct2func.mat -out $output_dir/fMRI_aparc+aseg.nii.gz
flirt -interp nearestneighbour -in $1/freesurfer/$2/surf/SUMA/aparc+aseg.nii.gz -ref $output_dir/${base}_reference_$minindex".nii" -applyxfm -init $output_dir/struct2func.mat -out $output_dir/fMRI_aparc+aseg.nii.gz


echo -n "" >  $output_dir/fMRI_aparc.a2009s+aseg_mean_ROI_timecourse.csv

foreach line ( "`cat aparc.a2009s+aseg.roi`" )
    set label=`echo $line| cut -d' ' -f1`
    set label_num=`echo $line| cut -d' ' -f2`
    echo $label - $label_num
    echo -n $label, >> $output_dir/fMRI_aparc.a2009s+aseg_mean_ROI_timecourse.csv

    echo 3dmaskave -quiet -mrange $label_num $label_num -mask  $output_dir/fMRI_aparc.a2009s+aseg.nii.gz $output_dir/$OUTFILE saveto $output_dir/fMRI_aparc.a2009s+aseg_mean_ROI_timecourse.csv
    3dmaskave -quiet -mrange $label_num $label_num -mask  $output_dir/fMRI_aparc.a2009s+aseg.nii.gz $output_dir/$OUTFILE| tr '\n' ',' >> $output_dir/fMRI_aparc.a2009s+aseg_mean_ROI_timecourse.csv
    echo "\n" >> $output_dir/fMRI_aparc.a2009s+aseg_mean_ROI_timecourse.csv
end

echo -n "" >  $output_dir/fMRI_aparc+aseg_mean_ROI_timecourse.csv
foreach line ( "`cat aparc+aseg.roi`" )
    set label=`echo $line| cut -d' ' -f1`
    set label_num=`echo $line| cut -d' ' -f2`
    echo $label - $label_num
    echo -n $label, >> $output_dir/fMRI_aparc+aseg_mean_ROI_timecourse.csv

    echo 3dmaskave -quiet -mrange $label_num $label_num -mask  $output_dir/fMRI_aparc+aseg.nii.gz $output_dir/$OUTFILE saveto $output_dir/fMRI_aparc+aseg_mean_ROI_timecourse.csv
    3dmaskave -quiet -mrange $label_num $label_num -mask  $output_dir/fMRI_aparc+aseg.nii.gz $output_dir/$OUTFILE | tr '\n' ',' >> $output_dir/fMRI_aparc+aseg_mean_ROI_timecourse.csv
	echo "\n" >  $output_dir/fMRI_aparc+aseg_mean_ROI_timecourse.csv
	
end


echo $OUTFILE
