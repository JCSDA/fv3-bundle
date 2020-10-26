#!/bin/bash

# ---------------------------
function get_dir {
    ans=''
    while [[ ! -d $dir ]]; do
      echo "Please enter the JEDI build directory"
      read indir < /dev/stdin
      dir=$(eval echo $indir)
      echo $dir
      [[ ! -d $dir ]] && echo "Sorry - that directory doesn't exist"
    done
}

# ---------------------------
# Path to fv3-bundle

JEDI_BUILD_DIR=${1:-"/opt/jedi/fv3-bundle/build"}

if [[ ! -d ${JEDI_BUILD_DIR} ]]; then
   get_dir
   JEDI_BUILD_DIR=$dir
fi

echo "JEDI build directory = "${JEDI_BUILD_DIR}

# Create directories to store output
# --------------------------------
mkdir -p run-output/hofx/

# ---------------------------------------------------------
# Define JEDI bin directory where the executables are found
export jedibin=${JEDI_BUILD_DIR}/bin

# ---------------------------------------------------------
# Define Environment variables
export OMP_NUM_THREADS=1

# ------------------------------------------------------
# Run the Hofx application

mpirun -n 12 $jedibin/fv3jedi_hofx_nomodel.x config/hofx3d.jedi.yaml

exit 0
