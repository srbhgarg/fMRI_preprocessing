3dTstat -prefix  $output_dir/rm.mean_values $output_dir/bet_$OUTFILE

3dcalc -a $output_dir/bet_$OUTFILE -b  $output_dir/rm.mean_values+orig \
           -c  $output_dir/bet_motion_corrected_mask.nii.gz          \
           -expr 'c * min(2000, a/b*1000)*step(a)*step(b)'       \
           -prefix $output_dir/scaled_$OUTFILE


