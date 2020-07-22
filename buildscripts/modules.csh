#!/bin/csh
set myshell=`echo $shell | rev | cut -d"/" -f1 | rev`
source $MODULESHOME/init/$myshell
module purge
setenv OPT OPTPATH
module use $OPT/modulefiles
module load MODLOAD
module list
