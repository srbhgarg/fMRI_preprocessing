#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and perform motion correction
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing Motion correction using MCIVA ..."

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

set OUTFILE="$base"_mciva.nii
if ( ! -f "$output_dir/$OUTFILE" ) then

	: create matlab script to run
        echo  "  addpath('/home/lab-x399-2/Documents/Scripts/nii');   \
	addpath('/home/lab-x399-2/Documents/Scripts/load_nii/');      \
	addpath('/home/lab-x399-2/Documents/Scripts/MCIVA'); \
        fmri_in = load_nii_unzip('$output_dir/$file');\
		\
	%% parameters \
	data_size = size(fmri_in.img);  % 80 80 36 240 \
	volume_size = data_size(1:3);   % size of the brain of a single timepoint \
	num_frame = data_size(4);       % number of timepoints \
	fmri_image = fmri_in.img;       % brain image \
		\
	%% variables  \
	num_refs = round(0.15*num_frame);      % number of reference timepoints  = 20% of total frames \
	data_IVA = zeros(num_frame,prod(volume_size)); \
	\
	s=1;\
	for iv = 1:num_frame \
		data_IVA(iv,:) = reshape(fmri_image(:,:,:,iv),1,prod(volume_size)); \
	end \
		\
    	[corrected_data, new_pointer, reference_timepoints, cost_vector] = motioncorrection_IVA_gpu(data_IVA,num_refs,s,volume_size(1),volume_size(2)); \
	fmri_out = fmri_in; \
	output_image = zeros(volume_size);\
	for iv = 1:num_frame \
		output_image(new_pointer) = corrected_data(iv,:); \
		fmri_out.img(:,:,:,iv) = output_image; \
	end \
	\
	save_untouch_nii(fmri_out,'$output_dir/$OUTFILE'); \
        clear new_pointer corrected_image data_IVA output_image fmri_in fmri_out  " > $output_dir/mciva_script.m


	: run the script
	echo matlab -nodisplay -nosplash -nodesktop -r "run('$output_dir/mciva_script.m');exit;"
	matlab -nodisplay -nosplash -nodesktop -r "run('$output_dir/mciva_script.m');exit;"
	if ( "$?" == "1" ) then
		echo "[Error] mcflirt failed with error"
		exit 1
	endif
	else
	echo "[Debug] motion  correction is already performed"
endif

echo $OUTFILE
