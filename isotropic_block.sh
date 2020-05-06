#!/bin/tcsh

: Takes fMRI NII/AFNI filename as input and perform isotropic resclicing
: Inputs: $1 Directory name
:         $2 subject name
:         $3 isotropic voxel size - integer
:         input file is obtained from OUTFILE environment variable
: Output: Output afni file name
:
: Author: Saurabh
: April 24 2020, PPRC @ UBC


echo "[Main] Performing Isotropic reslicing ..."

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


set outfilename=`ls $output_dir/*isotropic*.HEAD`

if ( ! -f "$outfilename" ) then
	echo 3dresample -dxyz $3 $3 $3 -rmode Cu  -prefix $output_dir/$base"_isotropic" -input  $output_dir/$file  
	3dresample -dxyz $3 $3 $3 -rmode Cu  -prefix $output_dir/$base"_isotropic" -input  $output_dir/$file  
	if ( "$?" == "1" ) then
		echo "[Error] 3dresample failed with error"
		exit 1
	endif
else
	echo "[Debug] isotropic resclicing is already performed"
endif

set OUTFILE=`ls $output_dir/*isotropic*.HEAD | xargs -n 1 basename`
echo $OUTFILE
