#/bin/tcsh
: Takes PAR/REC or DCM files and outputs NII filename. This expects input files : to be arranged in $1/$2/filename
: Inputs: $1 Directory name
:         $2 subject name
:         dcmfile is obtained from OUTFILE shell variable in output_dir
: Output: Output nii file name
:
: Author: Saurabh
: April 23 2020, PPRC @ UBC

echo "DCM 2 NII Step ........"

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

if ( $?OUTFILE ) then
	set file=$OUTFILE
else
    echo "[Error] OUTFILE env variable not set "
    exit 1
endif

set ext=`echo $file | cut -d'.' -f2`
set base=`echo $file | cut -d'.' -f1`

if( $ext == 'dcm' ||$ext == 'DCM') then
  if ( ! -d "$output_dir/$file" ) then
    echo "[Error] Input dcm dir $output_dir/$file not found "
    exit 1
  endif
else 
  if ( ! -f "$output_dir/$file" ) then
    : check directory instead  of file in case of dicom
    echo "[Error] Input file $output_dir/$file not found "
    exit 1
  endif
endif

: check if the file has right extension
: All the input checks cleared
if ( $ext == "PAR" || $ext == "REC"|| $ext == "par" || $ext == "rec" || $ext == "dcm" ||ext == "DCM") then
	: check if the step is already done
	set OUTFILE="co"$base".nii"
	if ( ! -f "$output_dir/$OUTFILE" ) then

		echo "[Debug] dcm2niix $output_dir/$file -o $output_dir/" 
		dcm2niix $output_dir/$file -o $output_dir/
		if [ "$?" = "1" ]; then
			echo "[Error] dcm2niix failed with error"
			exit 1
		endif
	else
		echo "[Debug] NII file already exists"
	endif
else if($ext == "nii" || $ext == "nii.gz") then
        set OUTFILE=$file
else
	echo "[Error] $ext not supported "
	exit 1
endif


