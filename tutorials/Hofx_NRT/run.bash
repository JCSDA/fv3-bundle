#!/bin/bash

# Experiment to run from user
# ---------------------------
export expid=$1
if [ -z "$1" ]
  then
    echo "Provide experiment id expid for running conf/expid.yaml"
    exit 0
else
  echo "Running" $expid
fi

# Create directories to store output
# --------------------------------
mkdir -p run-$expid/bump/
mkdir -p run-$expid/hofx/
mkdir -p run-$expid/logs/
mkdir -p run-$expid/analysis/
mkdir -p run-$expid/increment/


# Define JEDI bin directory where the executables are found
# ---------------------------------------------------------
export jedibin=/jedi/build/bin

# Define Environment variables
# ---------------------------------------------------------
export OMP_NUM_THREADS=1

# Run the BUMP parameter scripts to produce the B matrix
# ------------------------------------------------------
echo "Computing B matrix parameters using $expid-bumppar_cor.yaml and $expid-bumppar_loc.yaml"

mpirun -np 6 $jedibin/fv3jedi_parameters.x conf/$expid-bumppar_cor.yaml run-$expid/logs/$expid-bumppar_cor.log
mpirun -np 6 $jedibin/fv3jedi_parameters.x conf/$expid-bumppar_loc.yaml run-$expid/logs/$expid-bumppar_loc.log


# Run the variational application
# -------------------------------
mpirun -np 6 $jedibin/fv3jedi_var.x conf/$expid.yaml run-$expid/logs/$expid.log


# Compute the increment for plotting
# ----------------------------------
mpirun -np 6 $jedibin/fv3jedi_diffstates.x conf/$expid-diffstates.yaml run-hyb-3dvar/logs/$expid-diffstates.log
