MATLAB="/Applications/MATLAB_R2014a.app"
Arch=maci64
ENTRYPOINT=mexFunction
MAPFILE=$ENTRYPOINT'.map'
PREFDIR="/Users/kiana/.matlab/R2014a"
OPTSFILE_NAME="./mexopts.sh"
. $OPTSFILE_NAME
COMPILER=$CC
. $OPTSFILE_NAME
echo "# Make settings for tilt" > tilt_mex.mki
echo "CC=$CC" >> tilt_mex.mki
echo "CFLAGS=$CFLAGS" >> tilt_mex.mki
echo "CLIBS=$CLIBS" >> tilt_mex.mki
echo "COPTIMFLAGS=$COPTIMFLAGS" >> tilt_mex.mki
echo "CDEBUGFLAGS=$CDEBUGFLAGS" >> tilt_mex.mki
echo "CXX=$CXX" >> tilt_mex.mki
echo "CXXFLAGS=$CXXFLAGS" >> tilt_mex.mki
echo "CXXLIBS=$CXXLIBS" >> tilt_mex.mki
echo "CXXOPTIMFLAGS=$CXXOPTIMFLAGS" >> tilt_mex.mki
echo "CXXDEBUGFLAGS=$CXXDEBUGFLAGS" >> tilt_mex.mki
echo "LD=$LD" >> tilt_mex.mki
echo "LDFLAGS=$LDFLAGS" >> tilt_mex.mki
echo "LDOPTIMFLAGS=$LDOPTIMFLAGS" >> tilt_mex.mki
echo "LDDEBUGFLAGS=$LDDEBUGFLAGS" >> tilt_mex.mki
echo "Arch=$Arch" >> tilt_mex.mki
echo OMPFLAGS= >> tilt_mex.mki
echo OMPLINKFLAGS= >> tilt_mex.mki
echo "EMC_COMPILER=Xcode with Clang" >> tilt_mex.mki
echo "EMC_CONFIG=optim" >> tilt_mex.mki
"/Applications/MATLAB_R2014a.app/bin/maci64/gmake" -B -f tilt_mex.mk
