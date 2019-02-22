#!/bin/sh

set -e

# Usage of this script.
usage() { echo "Usage: $(basename $0) [-c gcc-7.3|intel-17.0.7.259] [-b debug|release] [-m fv3jedi|geos|gfs] [-n <1-12>] [-x]" 1>&2; exit 1; }

# Set defaults for input arguments.
compiler="gcc-7.3"
build="debug"
clean="NO"
model="fv3jedi"
nthreads=12
geos_path="/gpfsm/dnb31/drholdaw/GEOSagcm-Jason-GH/Linux"


# Parse input arguments.
while getopts 'xhc:b:m:n:' OPTION; do
  case "$OPTION" in
    x)
        clean="YES"
        ;;
    b)
        build="$OPTARG"
        [[ "$build" == "debug" || "$build" == "release" ]] || usage
        ;;
    c)
        compiler="$OPTARG"
        [[ "$compiler" == "gcc-7.3" || "$compiler" == "intel-17.0.7.259" ]] || usage
        ;;
    m)
        model="$OPTARG"
        [[ "$model" == "fv3jedi" || "$model" == "geos" || "$model" == "gfs" ]] || usage
        ;;
    n)
        n="$OPTARG"
        [[ $n -lt 1 || $n -gt 12 ]] && usage
        nthreads=$n
        ;;
    h|?)
        usage
        ;;
  esac
done
shift "$(($OPTIND -1))"

echo "compiler = $compiler"
echo "   build = $build"
echo "   model = $model"
echo " threads = $nthreads"
echo "   clean = $clean"

if [[ $model == "geos" ]]; then
    read -p "Enter the path for GEOS model [default: $geos_path] " choice
    [[ $choice == "" ]] && FV3BASEDMODEL_PATH=$geos_path || FV3BASEDMODEL_PATH=$choice
fi

# Set up JEDI specific modules.
source $MODULESHOME/init/sh
module purge
module use -a /discover/nobackup/projects/gmao/obsdev/rmahajan/opt/modulefiles
module load apps/jedi/$compiler
module list

# Set up FV3JEDI specific paths.
FV3JEDI_SRC=$(pwd)
FV3JEDI_BUILD=${FV3JEDI_SRC}/build-$compiler-$build

case "$clean" in
    Y|YES ) rm -rf $FV3JEDI_BUILD ;;
    * ) ;;
esac

mkdir -p $FV3JEDI_BUILD && cd $FV3JEDI_BUILD

ecbuild --build=$build -DMPIEXEC=$MPIEXEC $FV3JEDI_SRC
make -j$nthreads

ctest

exit 0
