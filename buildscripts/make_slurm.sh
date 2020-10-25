#!/bin/sh

#SBATCH -A ACCOUNT
#SBATCH --qos=QUEUE
#SBATCH --job-name=jedimake
#SBATCH --output=jedimake.o%j
#SBATCH --ntasks-per-node=24
#SBATCH --nodes=1
#SBATCH --time=00:30:00

cd BUILDDIR

source $MODULESHOME/init/sh
module purge
OPT=OPTPATH
module use $OPT/modulefiles/core
module use $OPT/modulefiles/apps
module load MODLOAD
module list

cd fv3-jedi

make -j12