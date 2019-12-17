#!/bin/sh

set -e

# Usage of this script.
usage() { echo "Usage: $(basename $0) [-c intel-19.0.5.281] [-b debug|release] [-m default|gfs] [-n 1..12] [-t ON|OFF] [-x] [-v] [-h]" 1>&2; exit 1; }

# Set input argument defaults.
compiler="intel-19.0.5.281"
build="release"
clean="NO"
model="default"
nthreads=12
run_ctest="OFF"
verbose="OFF"

# Set defaults for model paths.
gfs_path="/dev/null"


# Parse input arguments.
while getopts 'v:t:xhc:b:m:n:' OPTION; do
  case "$OPTION" in
    b)
        build="$OPTARG"
        [[ "$build" == "debug" || \
           "$build" == "release" ]] || usage
        ;;
    c)
        compiler="$OPTARG"
        [[ "$compiler" == "intel-19.0.5.281" ]] || usage
        ;;
    m)
        model="$OPTARG"
        [[ "$model" == "default" || \
           "$model" == "geos" || \
           "$model" == "gfs" ]] || usage
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
    h|?)
        usage
        ;;
  esac
done
shift "$(($OPTIND -1))"

echo "Summary of input arguments:"
echo "   build = $build"
echo "compiler = $compiler"
echo "   model = $model"
echo " threads = $nthreads"
echo "   ctest = $run_ctest"
echo "   clean = $clean"
echo " verbose = $verbose"
echo

# Load JEDI modules.
source $MODULESHOME/init/sh
module purge
module use -a /scratch1/NCEPDEV/da/Daniel.Holdaway/opt/modulefiles
module load apps/jedi/$compiler

# Set up model specific paths for ecbuild.
case "$model" in
    "default" )
        MODEL=""
        ;;
    "geos" )
        read -p "Enter the path for GEOS model [default: $geos_path] " choice
        [[ $choice == "" ]] && GEOS_PATH=$geos_path || GEOS_PATH=$choice
        MODEL="-DBUILD_WITH_GEOS=ON -DGEOS_PATH=$GEOS_PATH -DBASELIBDIR=$BASELIBDIR"
        ;;
    "gfs" )
        module use -a /discover/nobackup/projects/gmao/obsdev/drholdaw/opt/modulefiles
        module load apps/gfs/$compiler
        MODEL="-DBUILD_WITH_GFS=ON"
        ;;
esac

module list

# Set up FV3JEDI specific paths.
FV3JEDI_BUILD="$PWD/build-$compiler-$build-$model"
cd $(dirname $0)/..
FV3JEDI_SRC=$(pwd)

case "$clean" in
    Y|YES ) rm -rf $FV3JEDI_BUILD ;;
    * ) ;;
esac

mkdir -p $FV3JEDI_BUILD && cd $FV3JEDI_BUILD

ecbuild --build=$build -DMPIEXEC=$MPIEXEC $MODEL $FV3JEDI_SRC
make -j$nthreads

[[ $run_ctest == "ON" ]] && ctest

exit 0
