#!/bin/tcsh

: Takes fMRI NII filename as input and discard initial timepoints
: Inputs: $1 Directory name
:         $2 subject name
:         dcmfile is obtained from OUTFILE environment variable
:         $3 How many time points to discard
: Output: Output afni file name
:
: Author: Saurabh
: April 23 2020, PPRC @ UBC




echo "[Main] Discarding $3 volumes ..."

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

set outfilename=`ls $output_dir/*discarded*.BRIK`
: check if this step is already done
if ( ! -f "$outfilename" ) then
	echo "[Debug] 3dTcat -prefix $output_dir/${base}_discarded   $output_dir/$file'[${3}..]'"
	3dTcat -prefix $output_dir/"$base"_discarded   $output_dir/$file\[${3}..\$\]
	if ( "$?" == "1" ) then
		echo "[Error] 3dTcat failed with error"
		exit 1
	endif
else
	echo "[Debug] Initial volumes are already discarded"
endif

set OUTFILE=`ls $output_dir/*discarded*.BRIK | xargs -n 1 basename`
echo $OUTFILE
