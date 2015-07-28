if [
$# -lt 2 ] 

then

echo -e
"\nUsage:\n$0 <input video path> <output video path> \n"

exit 1

fi 

input_path=$1
output_path=$2

PATH=$PATH:$HOME/bin
export PATH


/home/local/QCRI/kcalagari/bin/ffmpeg -i $input_path/*.mp4 -r 25 -f image2 /export/ds/KianaCalagari/Fast2D-3D/V3V_demo/temp_i/%d.png

#nohup /opt/MATLAB/bin/matlab -nodisplay -nosplash -nodesktop -r "main" > main.out 2> main.err < /dev/null &
/export/ds/KianaCalagari/Fast2D-3D/run_main.sh /usr/local/MATLAB/MATLAB_Compiler_Runtime/v83

/home/local/QCRI/kcalagari/bin/ffmpeg -framerate 25 -start_number 1 -i /export/ds/KianaCalagari/Fast2D-3D/V3V_demo/temp_o/%d.png -pix_fmt yuv420p  -c:v libx264 -preset veryslow -qp 10 $output_path/output.mp4


