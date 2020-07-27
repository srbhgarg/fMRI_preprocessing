#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and perform motion correction
: Inputs: $1 Directory name
:         $2 subject name
:         $3 string identifier
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing Motion correction using SPM ..."

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

set fext=`echo $file | tail -c 3`
if( $fext == 'gz' ) then
    gunzip $output_dir/$file
    set file=`basename $file .gz`
endif

set OUTFILE=r$file


if ( ! -f "$output_dir/$OUTFILE" ) then

	: create matlab script to run
        echo  "  addpath('/home/lab-x399-2/Documents/Scripts/nii');   \
	addpath('/home/lab-x399-2/Documents/Scripts/load_nii/');      \
	addpath('/home/lab-x399-2/Documents/SPM/spm12/'); \
		\
        %motion correction using SPM \
        file_list = char('$output_dir/$file'); \
            % refer to spm_realign.m for details; \
            flage.quality=0.9; \
            flage.sep=4; \
            flage.fwhm=5;\
            flage.rtm=1; \
            flage.interp=2; \
            flage.wrap=[0 0 0]; \
            flage.weight={}; \
             \
            spm_realign(file_list,flage); \
            \
            % refer to spm_reslice.m for details; \
            flagr.which=[2 1]; \
            flagr.interp=4; \
            flagr.wrap=[0 0 0]; \
            flagr.mask=1; \
            \
            spm_reslice(file_list,flagr); " > $output_dir/$3_spm_mc_script.m


	: run the script
	echo matlab -nodisplay -nosplash -nodesktop -r "run('$output_dir/$3_spm_mc_script.m');exit;"
	matlab -nodisplay -nosplash -nodesktop -r "run('$output_dir/$3_spm_mc_script.m');exit;"
	if ( "$?" == "1" ) then
		echo "[Error] spm motion correction failed with error"
		exit 1
	endif
	else
	echo "[Debug] spm motion  correction is already performed"
endif

echo $OUTFILE
