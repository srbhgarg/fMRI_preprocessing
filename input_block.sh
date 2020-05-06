#!/bin/tcsh
: Takes PAR/REC or DCM files and outputs NII filename. This expects input files : to be arranged in $1/$2/filename
: Inputs: $1 Directory name
:         $2 subject name
:         $3 input fmri file
: Output: Output  file name will be set in OUTFILE
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC

echo "Input filename Step ........"

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


if ( ! -f "$1/$2/$3" ) then
    echo "[Error] Input filename $1/$2/$3 not found "
    exit 1
endif


set output_dir=$1/$2"/PROCESSED_DATA/"
mkdir -p $output_dir

cp -rf $1/$2/$3 $output_dir/ 
if ( "$?" == "1" ) then
	echo "[Error] Copying Input files failed with error"
	exit 1
endif
set OUTFILE=$3
set base=`echo $OUTFILE | cut -d'.' -f1`
echo $OUTFILE

