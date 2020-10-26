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
# get desired instrument

if [ $# -ne 1 ]; then
   echo "Usage: "
   echo "./run.bash <instrument-name>"
   echo "Where <instrument-name> is one of these:"
   echo "Aircraft"
   echo "Amsua_n19"
   echo "Atms_n20"
   echo "Cris_n20"
   echo "GnssroBnd"
   echo "Radiosonde"
   echo "Satwinds"
   exit 0
fi

instrument=$1

# ---------------------------
# Path to fv3-bundle

#JEDI_BUILD_DIR="/opt/jedi/build"
JEDI_BUILD_DIR="$HOME/jedi/build"

if [[ ! -d ${JEDI_BUILD_DIR} ]]; then
   get_dir
   JEDI_BUILD_DIR=$dir
fi

echo "JEDI build directory = "${JEDI_BUILD_DIR}

# link to crtm coefficents
mkdir -p Data
ln -sf ${JEDI_BUILD_DIR}/fv3-jedi/test/Data/crtm Data/crtm
ln -sf ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/SpcCoeff/Little_Endian/atms_n20* Data/crtm
ln -sf ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/TauCoeff/ODPS/Little_Endian/atms_n20* Data/crtm
ln -sf ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/SpcCoeff/Little_Endian/cris-fsr_n20* Data/crtm
ln -sf ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/TauCoeff/ODPS/Little_Endian/cris-fsr_n20* Data/crtm

# Create directories to store output
# --------------------------------
mkdir -p output/hofx/

# ---------------------------------------------------------
# Define JEDI bin directory where the executables are found
export jedibin=${JEDI_BUILD_DIR}/bin

# ---------------------------------------------------------
# Define Environment variables
export OMP_NUM_THREADS=1

# ------------------------------------------------------
# Run the Hofx application

application=gfs

mpirun -n 12 $jedibin/fv3jedi_hofx_nomodel.x config/${instrument}_${application}.hofx3d.jedi.yaml

exit 0
