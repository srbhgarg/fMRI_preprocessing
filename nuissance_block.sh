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


set parfile=`ls $output_dir/*motion*.par | xargs -n 1 basename`

if ( ! -f "$output_dir/${base}_regression_cleaned.nii.gz" ) then

echo bet2 $output_dir/$OUTFILE $output_dir/bet_$OUTFILE -m
bet2 $output_dir/$OUTFILE $output_dir/bet_$OUTFILE -m -n 

#apply bet mask
3dcalc -a  $output_dir/$OUTFILE -b  $output_dir/bet_motion_corrected_mask.nii.gz -expr 'a*bool(b)' -prefix $output_dir/bet_$OUTFILE

: compute mean time course  and derivatives
# compute de-meaned motion parameters (for use in regression)
echo 1d_tool.py -infile $output_dir/$parfile -set_nruns 1 -demean -write $output_dir/motion_demean.1D
1d_tool.py -infile $output_dir/$parfile -set_nruns 1 -demean -write $output_dir/motion_demean.1D

1d_tool.py -infile $output_dir/CSF_Timecourse.1D -set_nruns 1 -demean -write $output_dir/CSF_Timecourse_demean.1D

1d_tool.py -infile $output_dir/ROIPC.FSvent.1D -set_nruns 1 -demean -write $output_dir/ROIPC_demean.FSvent.1D
# compute motion parameter derivatives (for use in regression)
1d_tool.py -infile $output_dir/$parfile -set_nruns 1                             \
           -derivative -demean -write $output_dir/motion_deriv.1D

#compute quadratic terms for motion
1deval -expr 'a*a' -a $output_dir/$parfile'[0]' > /tmp/square0
1deval -expr 'a*a' -a $output_dir/$parfile'[1]' > /tmp/square1
1deval -expr 'a*a' -a $output_dir/$parfile'[2]' > /tmp/square2
1deval -expr 'a*a' -a $output_dir/$parfile'[3]' > /tmp/square3
1deval -expr 'a*a' -a $output_dir/$parfile'[4]' > /tmp/square4
1deval -expr 'a*a' -a $output_dir/$parfile'[5]' > /tmp/square5

1dcat  /tmp/square0  /tmp/square1  /tmp/square2   /tmp/square3  /tmp/square4  /tmp/square5 > $output_dir/motion.quadratic

1d_tool.py -infile  $output_dir/motion.quadratic  -set_nruns 1 -demean -write  $output_dir/motion.quadratic_demean
rm /tmp/square*

#compute quadratic terms for motion
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[0]' > /tmp/square0
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[1]' > /tmp/square1
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[2]' > /tmp/square2
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[3]' > /tmp/square3
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[4]' > /tmp/square4
1deval -expr 'a*a' -a $output_dir/motion_deriv.1D'[5]' > /tmp/square5

1dcat  /tmp/square0  /tmp/square1  /tmp/square2   /tmp/square3  /tmp/square4  /tmp/square5 > $output_dir/motion_deriv.quadratic

1d_tool.py -infile  $output_dir/motion_deriv.quadratic  -set_nruns 1 -demean -write  $output_dir/motion_deriv.quadratic_demean
rm /tmp/square*


1dcat $output_dir/ROIPC_demean.FSvent.1D  $output_dir/CSF_Timecourse_demean.1D $output_dir/motion_demean.1D  $output_dir/motion_deriv.1D $output_dir/motion.quadratic_demean $output_dir/motion_deriv.quadratic > $output_dir/nuisance_regression_params.txt

	   
# create bandpass regressors (instead of using 3dBandpass, say)
1dBport -nodata 1356 0.53 -band 0.01 0.1 -invert -nozero > $output_dir/bandpass_rall.1D


# ------------------------------
# run the regression analysis
	#    -censor $output_dir/censor_${base}_combined_2.1D         \
		#    -ortvec $output_dir/bandpass_rall.1D bandpass                                    \
3dDeconvolve -input $output_dir/bet_$OUTFILE                         \
    -ortvec $output_dir/nuisance_regression_params.txt motion \
    -num_stimts 0 \                                                        
    -polort -1 -float                                                      \
    -mask   $output_dir/bet_motion_corrected_mask.nii.gz                                \
    -fout -tout -x1D  $output_dir/X.xmat.1D -xjpeg  $output_dir/X.jpg                    \
    -x1D_uncensored  $output_dir/X.nocensor.xmat.1D                                    \
    -fitts  $output_dir/fitts.${base}                                                    \
    -errts  $output_dir/errts.${base}                                                  \
    -x1D_stop                                                                     \
    -bucket  $output_dir/stats.$base
	if ( "$?" == "1" ) then
		echo "[Error] 3dDeconvolve failed with error"
		exit 1
	endif
# -- use 3dTproject to project out regression matrix --
#    (make errts like 3dDeconvolve, but more quickly)
	#	-censor $output_dir/censor_${base}_combined_2.1D -cenmode ZERO            \
3dTproject -polort -1 -input  $output_dir/bet_$OUTFILE -mask  $output_dir/bet_motion_corrected_mask.nii.gz                \
           -ort $output_dir/X.nocensor.xmat.1D -prefix $output_dir/${base}_regression_cleaned.nii.gz
	if ( "$?" == "1" ) then
		echo "[Error] 3dTproject failed with error"
		exit 1
	endif
else
	echo "[Debug] co-registration is already performed"
endif

set OUTFILE=${base}_regression_cleaned.nii.gz
echo $OUTFILE
