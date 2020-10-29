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
instrlist=(Aircraft Amsua_n19 Atms_n20 GnssroBnd Radiosonde Satwinds Medley)

if [ $# -ne 1 ]; then
   echo "Usage: "
   echo "./run.bash <instrument-name>"
   echo "Where <instrument-name> is one of these:"
   for instr in "${instrlist[@]}"; do
       echo $instr
   done
   exit 0
fi

instrument=$1

if [[ " ${instrlist[@]} " =~ " ${instrument} " ]]; then
   echo "instrument = " $instrument
else
   echo "You must pick an instrument from the list"
   exit 0
fi

# ---------------------------
# Path to fv3-bundle

JEDI_BUILD_DIR=${JEDI_BUILD_DIR:-/opt/jedi/build}

if [[ ! -d ${JEDI_BUILD_DIR} ]]; then
   get_dir
   JEDI_BUILD_DIR=$dir
fi

echo "JEDI build directory = "${JEDI_BUILD_DIR}

# link to crtm coefficents
mkdir -p Data
cp -r ${JEDI_BUILD_DIR}/fv3-jedi/test/Data/crtm Data/crtm
cp ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/SpcCoeff/Little_Endian/* Data/crtm
cp ${JEDI_BUILD_DIR}/test_data/crtm/2.3.0/TauCoeff/ODPS/Little_Endian/* Data/crtm

# Create directories to store output
# --------------------------------
mkdir -p output/hofx/
mkdir -p output/binned/
mkdir -p output/plots/$instrument/

# ---------------------------------------------------------
# Define JEDI bin directory where the executables are found
export jedibin=${JEDI_BUILD_DIR}/bin

# ---------------------------------------------------------
# Define Environment variables
export OMP_NUM_THREADS=1

# ------------------------------------------------------
# Run the Hofx application

if [[ ${instrument} == Aircraft ]]; then
    prefix=hofx3d_gfs_c48_ncdiag_aircraft_PT6H_20201001_0300Z
    varlist=(air_temperature eastward_wind northward_wind specific_humidity)
elif [[ ${instrument} == Amsua_n19 ]]; then
    prefix=hofx3d_gfs_c48_ncdiag_amsua-n19_PT6H_20201001_0300Z
    varlist=(brightness_temperature_12)
elif [[ ${instrument} == Atms_n20 ]]; then
    prefix=hofx3d_gfs_c48_ncdiag_atms-n20_PT6H_20201001_0300Z
    varlist=(brightness_temperature_1 brightness_temperature_2 brightness_temperature_3 \
             brightness_temperature_4 brightness_temperature_5 brightness_temperature_6 \
             brightness_temperature_7 brightness_temperature_5 brightness_temperature_6 \
             brightness_temperature_10 brightness_temperature_11 brightness_temperature_12 \
             brightness_temperature_13 brightness_temperature_14 brightness_temperature_15 \
             brightness_temperature_16 brightness_temperature_17 brightness_temperature_18 \
             brightness_temperature_19 brightness_temperature_20 brightness_temperature_21 \
             brightness_temperature_22)
elif [[ ${instrument} == GnssroBnd ]]; then
    prefix=hofx3d_gfs_c48_nomads_gnssro_PT6H_20201001_0300Z
    varlist=(bending_angle)
elif [[ ${instrument} == Radiosonde ]]; then
    prefix=hofx3d_gfs_c48_ncdiag_radiosonde_PT6H_20201001_0300Z
    varlist=(air_temperature eastward_wind northward_wind)
elif [[ ${instrument} == Satwinds ]]; then
    prefix=hofx3d_gfs_c48_ncdiag_satwind_PT6H_20201001_0300Z
    varlist=(eastward_wind northward_wind)
else
    echo "Medley option is run only: not generating plots"
    exit 0
fi

application=gfs

mpirun -n 12 $jedibin/fv3jedi_hofx_nomodel.x config/${instrument}_${application}.hofx3d.jedi.yaml

# ------------------------------------------------------
# Bin the output to get obs counts

iodaplots bin output/hofx/${prefix}* -o output/binned/${instrument}.nc4 -c config/${instrument}_gfs.plot.yaml
iodaplots plot -e ${instrument} output/binned/${instrument}.nc4 -o output/plots/${instrument}/- -c config/${instrument}_gfs.plot.yaml

# ------------------------------------------------------
# Make the plots

chmod +x plot_from_ioda_hofx.py

cd output/plots/${instrument}

for var in "${varlist[@]}"; do
   ../../../plot_from_ioda_hofx.py --hofxfiles ../../hofx/${prefix}_NPROC.nc4 --variable ${var}@ObsValue --nprocs 12 --window_begin 2020100103
   ../../../plot_from_ioda_hofx.py --hofxfiles ../../hofx/${prefix}_NPROC.nc4 --variable ${var}@hofx --nprocs 12 --window_begin 2020100103
   ../../../plot_from_ioda_hofx.py --hofxfiles ../../hofx/${prefix}_NPROC.nc4 --variable ${var}@hofx --omb=True --nprocs 12 --window_begin 2020100103
done

exit 0
