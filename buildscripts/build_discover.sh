#!/bin/sh

set -e

# Usage of this script.
usage() { echo "Usage: $(basename $0) [-c intel-17.0.7.259|gcc-7.3_openmpi-3.0.0|gcc-7.3_mpich-3.3|intel-18.0.5.274] [-b debug|release] [-m default|geos|gfs] [-n 1..12] [-t ON|OFF] [-x] [-v] [-h]" 1>&2; exit 1; }

# Set input argument defaults.
compiler="intel-17.0.7.259"
build="debug"
clean="NO"
model="default"
nthreads=12
run_ctest="ON"
verbose="OFF"

# Set defaults for model paths.
geos_path="/gpfsm/dnb31/drholdaw/GEOSagcm-Jason-GH/Linux"
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
        [[ "$compiler" == "gcc-7.3_openmpi-3.0.0" || \
           "$compiler" == "gcc-7.3_mpich-3.3" || \
           "$compiler" == "intel-17.0.7.259" || \
           "$compiler" == "intel-18.0.5.274" ]] || usage
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
module use -a /discover/nobackup/projects/gmao/obsdev/rmahajan/opt/modulefiles
module load apps/jedi/$compiler
module list

# Set up model specific paths for ecbuild.
case "$model" in
    "default" )
        MODEL=""
        ;;
    "geos" )
        read -p "Enter the path for GEOS model [default: $geos_path] " choice
        [[ $choice == "" ]] && FV3BASEDMODEL_PATH=$geos_path || FV3BASEDMODEL_PATH=$choice
        MODEL="-DFV3BASEDMODEL_PATH=$FV3BASEDMODEL_PATH -DBASELIBDIR=$BASELIBDIR"
        ;;
    "gfs" )
        read -p "Enter the path for GFS model [default: $gfs_path] " choice
        [[ $choice == "" ]] && FV3BASEDMODEL_PATH=$gfs_path || FV3BASEDMODEL_PATH=$choice
        MODEL="-DFV3BASEDMODEL_PATH=$FV3BASEDMODEL_PATH"
        ;;
esac

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
make update
cd fv3-jedi
make -j$nthreads

[[ $run_ctest == "ON" ]] && ctest

exit 0
