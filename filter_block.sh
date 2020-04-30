#!/bin/tcsh

: Takes fMRI NII filename as input and performs temporal filtering
: Inputs: $1 Directory name
:         $2 subject name
:         dcmfile is obtained from OUTFILE environment variable
:         $3 low freq cutoff [0.01Hz]
:         $4 High freq cutoff [0.1Hz]
: Output: Output afni file name
:
: Author: Saurabh
: April 23 2020, PPRC @ UBC




echo "[Main] Performing Temporal filtering  ..."

if ($#argv != 4) then
    echo "[Error] Insufficient number of input arguments. Expected 4 got $#argv"
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
set OUTFILE="$base"_filtered+tlrc.BRIK

: check if this step is already done
if ( ! -f "$output_dir/$OUTFILE" ) then
	
	echo 3dBandpass  -prefix $output_dir/"$base"_filtered $3 $4  $output_dir/$file
	3dBandpass  -prefix $output_dir/"$base"_filtered $3 $4  $output_dir/$file
	if ( "$?" == "1" ) then
		echo "[Error] 3dBandpass failed with error"
		exit 1
	endif
else
	echo "[Debug] Initial volumes are already discarded"
endif

echo $OUTFILE
