#/bin/bash

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
mkdir -p bump/
mkdir -p run-$expid/hofx/
mkdir -p run-$expid/logs/
mkdir -p run-$expid/analysis/
mkdir -p run-$expid/increment/

# Define JEDI bin directory where the executables are found
# ---------------------------------------------------------
#export jedibuild=/jedi/build
export jedibuild=$HOME/jedi/build

export jedibin=$jedibuild/bin

# Define Environment variables
# ---------------------------------------------------------
export OMP_NUM_THREADS=1

# Run the BUMP parameter scripts to produce the B matrix
# ------------------------------------------------------
echo "Computing B matrix parameters"

mpirun -np 6 $jedibin/fv3jedi_parameters.x config/bumpparameters_nicas_gfs.yaml 

# Run the variational application
# -------------------------------
mpirun -np 6 $jedibin/fv3jedi_var.x config/$expid.yaml

exit 0

# Compute the increment for plotting
# ----------------------------------
mpirun -np 6 $jedibin/fv3jedi_diffstates.x config/$expid-diffstates.yaml
