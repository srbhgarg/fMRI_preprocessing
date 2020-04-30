#!/bin/tcsh

: Takes fMRI NII/AFNI and performs nuissance regression 
: Inputs: $1 Directory name
:         $2 subject name
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 25 2020, PPRC @ UBC


echo "[Main] Performing nuissance  regression ..."

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


set parfile=`echo $OUTFILE|cut -d'.' -f1`.par

if ( ! -f "$output_dir/${base}_regression_cleaned.nii" ) then

: compute mean time course  and derivatives
# compute de-meaned motion parameters (for use in regression)
1d_tool.py -infile $output_dir/$parfile -set_nruns 1                             \
           -demean -write $output_dir/motion_demean.1D

# compute motion parameter derivatives (for use in regression)
1d_tool.py -infile $output_dir/$parfile -set_nruns 1                             \
           -derivative -demean -write $output_dir/motion_deriv.1D

# convert motion parameters for per-run regression
1d_tool.py -infile $output_dir/motion_demean.1D -set_nruns 1                          \
           -split_into_pad_runs $output_dir/mot_demean

1d_tool.py -infile $output_dir/motion_deriv.1D -set_nruns 1                           \
           -split_into_pad_runs $output_dir/mot_deriv


# ------------------------------
# run the regression analysis
3dDeconvolve -input $output_dir/$OUTFILE                         \
    -ortvec  $output_dir/ROIPC.FSvent.1D  $output_dir/ROIPC.FSvent                          \
    -ortvec  $output_dir/CSF_Timecourse.1D  $output_dir/CSF_Timecourse                        \
    -ortvec  $output_dir/mot_demean.r01.1D   $output_dir/mot_demean                              \
    -ortvec  $output_dir/mot_deriv.r01.1D  $output_dir/mot_deriv                                \
    -polort 2 -float                                                      \
    -num_stimts 0                                                         \
    -fout -tout -x1D  $output_dir/X.xmat.1D -xjpeg  $output_dir/X.jpg                               \
    -x1D_uncensored  $output_dir/X.nocensor.xmat.1D                                    \
    -fitts  $output_dir/fitts.${base}                                                    \
    -errts  $output_dir/errts.${base}                                                  \
    -x1D_stop                                                             \
    -bucket  $output_dir/stats.$base
	if ( "$?" == "1" ) then
		echo "[Error] 3dDeconvolve failed with error"
		exit 1
	endif
# -- use 3dTproject to project out regression matrix --
#    (make errts like 3dDeconvolve, but more quickly)
3dTproject -polort 0 -input  $output_dir/$OUTFILE                \
           -ort $output_dir/X.nocensor.xmat.1D -prefix $output_dir/${base}_regression_cleaned.nii
	if ( "$?" == "1" ) then
		echo "[Error] 3dTproject failed with error"
		exit 1
	endif
else
	echo "[Debug] co-registration is already performed"
endif

set OUTFILE=${base}_regression_cleaned.nii
echo $OUTFILE
