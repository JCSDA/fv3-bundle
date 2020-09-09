#!/bin/sh

set -e

# Usage of this script.
usage() { echo "Usage: $(basename $0) [-c intel-impi/19.1.0.166|gnu-impi/9.2.0|baselibs/intel-impi/19.1.0.166] [-b debug|relwithdebinfo|release|bit|production] [-m fv3|geos|ufs] [-p DOUBLE|SINGLE] [-n 1..12] [-t ON|OFF] [-q debug|advda] [-x] [-v] [-h]" 1>&2; exit 1; }

# Set input argument defaults.
compiler="intel-impi/19.1.0.166"
build="debug"
clean="NO"
model="fv3"
nthreads=12
run_ctest="ON"
verbose="OFF"
account="g0613"
queue="debug"
fv3lmprec="DOUBLE"

# Parse input arguments.
while getopts 'v:t:xhc:q:b:m:p:n:' OPTION; do
  case "$OPTION" in
    b)
        build="$OPTARG"
        [[ "$build" == "debug" || \
           "$build" == "relwithdebinfo" || \
           "$build" == "bit" || \
           "$build" == "release" || \
           "$build" == "production" ]] || usage
        ;;
    c)
        compiler="$OPTARG"
        [[ "$compiler" == "gnu-impi/9.2.0" || \
           "$compiler" == "intel-impi/19.1.0.166" || \
           "$compiler" == "baselibs/intel-impi/19.1.0.166" ]] || usage
        ;;
    m)
        model="$OPTARG"
        [[ "$model" == "fv3" || \
           "$model" == "geos" || \
           "$model" == "ufs" ]] || usage
        ;;
    p)
        fv3lmprec="$OPTARG"
        [[ "$fv3lmprec" == "DOUBLE" || \
           "$fv3lmprec" == "SINGLE" ]] || usage
        ;;
    n)
        n="$OPTARG"
        [[ $n -lt 1 || $n -gt 12 ]] && usage
        nthreads=$n
        ;;
    t)
        run_ctest="$OPTARG"
        [[ "$run_ctest" == "ON" || \
           "$run_ctest" == "OFF" ]] || usage
        ;;
    x)
        clean="YES"
        ;;
    v)
        VERBOSE="ON"
        ;;
    a)
        account="g0613"
        ;;
    q)
        queue="$OPTARG"
        [[ "$queue" == "debug" || \
           "$queue" == "advda" ]] || usage
        ;;
    h|?)
        usage
        ;;
  esac
done
shift "$(($OPTIND -1))"

echo "Summary of input arguments:"
echo "         build = $build"
echo "      compiler = $compiler"
echo "         model = $model"
echo "lin model prec = $fv3lmprec"
echo "       threads = $nthreads"
echo "         ctest = $run_ctest"
echo "         clean = $clean"
echo "       verbose = $verbose"
echo "       account = $account"
echo "         queue = $queue"
echo

# Load JEDI modules.
OPTPATH=/discover/swdev/jcsda/modules
MODLOAD=jedi/$compiler

source $MODULESHOME/init/sh
module purge
export OPT=$OPTPATH
module use $OPT/modulefiles/core
module use $OPT/modulefiles/apps
module load $MODLOAD
module list

# Forecast model configuration
case "$model" in
    "fv3" )
       MODEL="$MODEL" #Leave blank to test that default builds properly
       FV3_PRECISION=$fv3lmprec
        ;;
    "geos" )
       MODEL="$MODEL -DFV3_FORECAST_MODEL=GEOS"
       FV3_PRECISION_DEFAULT=SINGLE
       # Forecast install directory
       FV3_FORECAST_MODEL_ROOT_DEFUALT=/discover/nobackup/drholdaw/Models/GEOS/Tags/GEOSgcm/GEOSgcm-default/install
       read -p "Enter the install path for the GEOS model [$FV3_FORECAST_MODEL_ROOT_DEFUALT] " FV3_FORECAST_MODEL_ROOT
       FV3_FORECAST_MODEL_ROOT=${FV3_FORECAST_MODEL_ROOT:-$FV3_FORECAST_MODEL_ROOT_DEFUALT}
       # Forecast run directory
       FV3_FORECAST_MODEL_RUNDIR_DEFUALT=/discover/nobackup/drholdaw/JediData/ModelRunDirs/geos-c24
       read -p "Enter the path for the GEOS testing directory [$FV3_FORECAST_MODEL_RUNDIR_DEFUALT] " FV3_FORECAST_MODEL_RUNDIR
       FV3_FORECAST_MODEL_RUNDIR=${FV3_FORECAST_MODEL_RUNDIR:-$FV3_FORECAST_MODEL_RUNDIR_DEFUALT}
       MODEL="$MODEL -DFV3_FORECAST_MODEL_ROOT=$FV3_FORECAST_MODEL_ROOT"
       MODEL="$MODEL -DFV3_FORECAST_MODEL_RUNDIR=$FV3_FORECAST_MODEL_RUNDIR"
       # Dyn core precision
       read -p "Enter the dynamical core precision, DOUBLE/SINGLE (should match preinstalled models): [$FV3_PRECISION_DEFAULT] " FV3_PRECISION
       FV3_PRECISION=${FV3_PRECISION:-$FV3_PRECISION_DEFAULT}
       MODEL="$MODEL -DBUNDLE_SKIP_ECKIT=OFF"
       ;;
    "ufs" )
       MODEL="$MODEL -DFV3_FORECAST_MODEL=UFS"
       FV3_PRECISION_DEFAULT=SINGLE
       # Forecast install directory
       FV3_FORECAST_MODEL_ROOT_DEFUALT=/gpfsm/dnb31/drholdaw/Models/NOAA/ufs-weather-model-cmake-build/install
       read -p "Enter the path for the UFS isntall directory [$FV3_FORECAST_MODEL_ROOT_DEFUALT] " FV3_FORECAST_MODEL_ROOT
       FV3_FORECAST_MODEL_ROOT=${FV3_FORECAST_MODEL_ROOT:-$FV3_FORECAST_MODEL_ROOT_DEFUALT}
       # Forecast run directory
       FV3_FORECAST_MODEL_RUNDIR_DEFUALT=/discover/nobackup/drholdaw/JediData/ModelRunDirs/gfs-c96
       read -p "Enter the path for the UFS testing directory [$FV3_FORECAST_MODEL_RUNDIR_DEFUALT] " FV3_FORECAST_MODEL_RUNDIR
       FV3_FORECAST_MODEL_RUNDIR=${FV3_FORECAST_MODEL_RUNDIR:-$FV3_FORECAST_MODEL_RUNDIR_DEFUALT}
       # Forecast src directory
       FV3_FORECAST_MODEL_SRC_DEFUALT=/gpfsm/dnb31/drholdaw/Models/NOAA/ufs-weather-model-cmake
       read -p "Enter the path for the UFS source directory [$FV3_FORECAST_MODEL_SRC_DEFUALT] " FV3_FORECAST_MODEL_SRC
       FV3_FORECAST_MODEL_SRC=${FV3_FORECAST_MODEL_SRC:-$FV3_FORECAST_MODEL_SRC_DEFUALT}
       MODEL="$MODEL -DFV3_FORECAST_MODEL_SRC=$FV3_FORECAST_MODEL_SRC"
       # Forecast build directory
       FV3_FORECAST_MODEL_BUILD_DEFUALT=/gpfsm/dnb31/drholdaw/Models/NOAA/ufs-weather-model-cmake-build
       read -p "Enter the path for the UFS build directory [$FV3_FORECAST_MODEL_BUILD_DEFUALT] " FV3_FORECAST_MODEL_BUILD
       FV3_FORECAST_MODEL_BUILD=${FV3_FORECAST_MODEL_BUILD:-$FV3_FORECAST_MODEL_BUILD_DEFUALT}
       MODEL="$MODEL -DFV3_FORECAST_MODEL_BUILD=$FV3_FORECAST_MODEL_BUILD"
       MODEL="$MODEL -DFV3_FORECAST_MODEL_ROOT=$FV3_FORECAST_MODEL_ROOT"
       MODEL="$MODEL -DFV3_FORECAST_MODEL_RUNDIR=$FV3_FORECAST_MODEL_RUNDIR"
       # Dyn core precision
       read -p "Enter the dynamical core precision, DOUBLE/SINGLE (should match preinstalled models): [$FV3_PRECISION_DEFAULT] " FV3_PRECISION
       FV3_PRECISION=${FV3_PRECISION:-$FV3_PRECISION_DEFAULT}
       ;;
esac


# Append with forecast model options
MODEL="$MODEL -DFV3LM_PRECISION=$fv3lmprec -DFV3_PRECISION=$FV3_PRECISION"

# Set up FV3JEDI specific paths.
compiler_build=`echo $compiler | tr / -`
FV3JEDI_BUILD="$PWD/build-$compiler_build-$build-$model"
cd $(dirname $0)/..
FV3JEDI_SRC=$(pwd)

# Add precision to build dir if single
if [ "$fv3lmprec" == "SINGLE" ]; then
  FV3JEDI_BUILD="${FV3JEDI_BUILD}-fv3lmsp"
fi

case "$clean" in
    Y|YES ) rm -rf $FV3JEDI_BUILD ;;
    * ) ;;
esac

mkdir -p $FV3JEDI_BUILD && cd $FV3JEDI_BUILD

# Create bash module file for future sourcing
# -------------------------------------------
file=modules.sh
cp ../buildscripts/$file ./
sed -i "s,OPTPATH,$OPTPATH,g" $file
sed -i "s,MODLOAD,$MODLOAD,g" $file

# Create csh/tsh module file for future sourcing
# ----------------------------------------------
file=modules.csh
cp ../buildscripts/$file ./
sed -i "s,OPTPATH,$OPTPATH,g" $file
sed -i "s,MODLOAD,$MODLOAD,g" $file

# Slurm job for running make
# --------------------------
file=make_slurm.sh
cp ../buildscripts/$file ./
sed -i "s,OPTPATH,$OPTPATH,g" $file
sed -i "s,MODLOAD,$MODLOAD,g" $file
sed -i "s,ACCOUNT,$account,g" $file
sed -i "s,QUEUE,$queue,g" $file
sed -i "s,BUILDDIR,$FV3JEDI_BUILD,g" $file

# Slurm job for running tests
# ---------------------------
file=ctest_slurm.sh
cp ../buildscripts/$file ./
sed -i "s,OPTPATH,$OPTPATH,g" $file
sed -i "s,MODLOAD,$MODLOAD,g" $file
sed -i "s,ACCOUNT,$account,g" $file
sed -i "s,QUEUE,$queue,g" $file
sed -i "s,BUILDDIR,$FV3JEDI_BUILD,g" $file

# Optional obs operators
# ----------------------
OBSOPS=""
#OBSOPS="-DBUNDLE_SKIP_GEOS-AERO=OFF -DBUNDLE_SKIP_ROPP-UFO=OFF" 

# Build
# -----
ecbuild --build=$build -DMPIEXEC=$MPIEXEC $MODEL $OBSOPS $FV3JEDI_SRC

# Update the repos
# ----------------
make update

# Build fv3-jedi
# --------------
sbatch --wait make_slurm.sh

# Data get test
# -------------
cd fv3-jedi
ctest -R fv3_get_ioda_test_data
cd ../

# Run ctests
# ----------
[[ $run_ctest == "ON" ]] && sbatch ctest_slurm.sh

exit 0
