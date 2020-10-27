#/bin/bash

# Experiment to run from user
# ---------------------------
explist=(3denvar 4denvar)

export expid=$1
if [ $# -ne 1 ]; then
   echo "Usage: "
   echo "./run.bash <application-name>"
   echo "Where <application-name> is one of these:"
   for exp in "${explist[@]}"; do
       echo $exp
   done
   exit 0
fi

if [[ " ${explist[@]} " =~ " ${expid} " ]]; then
   echo "Running " $expid
else
   echo "Sorry - You must pick an application from the list"
   for exp in "${explist[@]}"; do
       echo $exp
   done
   exit 0
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
export jedibuild=/opt/jedi/build
export jedibin=$jedibuild/bin

# Define Environment variables
# ---------------------------------------------------------
export OMP_NUM_THREADS=1

# Run the BUMP parameter scripts to produce the B matrix
# ------------------------------------------------------
echo "Computing B matrix parameters"

mpirun -np 6 $jedibin/fv3jedi_parameters.x config/bumpparameters_nicas_gfs.yaml run-$expid/logs/$expid-bumpparameters.log

# Run the variational application
# -------------------------------
[[ $expid == 4denvar ]] && ntasks=18 || ntasks=6
mpirun -np $ntasks $jedibin/fv3jedi_var.x config/$expid.yaml run-$expid/logs/$expid.log

# Compute the increment for plotting
# ----------------------------------
mpirun -np 6 $jedibin/fv3jedi_diffstates.x config/$expid-increment.yaml run-$expid/logs/$expid-increment.log

exit 0
