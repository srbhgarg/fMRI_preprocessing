#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and perform registration of HMAT atlas to structural scan
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing registration using LDDMM ..."

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

if ( ! -f "$1/$2/$OUTFILE" ) then
    echo "[Error] Input file $1/$2/$OUTFILE not found "
    exit 1
endif

set T1_file=$OUTFILE


set OUTFILE='HMAT_in_struct.nii'
if ( ! -f "$output_dir/$OUTFILE" ) then

	: create python lddmm script to run

	echo "import sys\
import os\
cwd=os.getcwd()\
sys.path.append(os.path.abspath('/home/lab-x399-2/Documents/ndreg/')) \
os.chdir('/home/lab-x399-2/Documents/ndreg/') \
import ndreg\
from ndreg import preprocessor, util, plotter \
import SimpleITK as sitk \
import os \
\
# register colin(in) to bet_t1_file (ref) - get affine and fields \
# apply affine to HMAT.nii and field to  bet\
# move the registered image to fMRI space using struct2func.mat \
\
colin = util.imgRead('/home/lab-x399-2/Documents/fMRI_preprocessing/colin27_t1_tal_lin_cropped2.nii') \
img = util.imgRead('$output_dir/bet_$T1_file') \
\
img_p = sitk.Normalize(img) \
colin_p = sitk.Normalize(colin) \
atlas_registered, field, final_transform = ndreg.register_brain(colin_p, img_p, outdir='$output_dir/LDDMM/') \
\
field_up = preprocessor.imgResample(field, colin.GetSpacing()) \
#atlas = util.imgRead('/home/lab-x399-2/Documents/fMRI_preprocessing/HMAT2.nii') \
atlas = util.imgRead('/home/lab-x399-2/Documents/fMRI_preprocessing/HMAT2.nii') \
atlas_affine_up = ndreg.imgApplyAffine(atlas, final_transform, size=img_p.GetSize()) \
atlas_lddmm_up = ndreg.imgApplyField(atlas_affine_up, field_up) \
\
util.imgWrite(atlas_affine_up, '$output_dir/HMAT_in_affine_struct.nii' )\
util.imgWrite(atlas_lddmm_up, '$output_dir/HMAT_in_struct.nii' )\
os.chdir(cwd) \" > $output_dir/lddmm.py


	: run the script
	python $output_dir/lddmm.py
	if ( "$?" == "1" ) then
		echo "[Error] LDDMM failed with error"
		exit 1
	endif
else
	echo "[Debug] LDDMM is already performed"
endif

echo $OUTFILE
