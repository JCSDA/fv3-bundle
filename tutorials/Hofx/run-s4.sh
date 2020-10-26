#!/usr/bin/bash
#------------------------------------------------------------------------------#
# s4
# run "sbatch run-s4.sh" to submit this job
#------------------------------------------------------------------------------#
#SBATCH --job-name=runhofx
#SBATCH --time=00:29:00
#SBATCH --partition=s4
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --account=jcsda

#------------------------------------------------------------------------------#
# Unlimit stack and virtual memory
#------------------------------------------------------------------------------#

  ulimit -s unlimited
  ulimit -v unlimited

#------------------------------------------------------------------------------#
# Load JEDI modules
#------------------------------------------------------------------------------#

source /etc/bashrc
module purge
export OPT=/data/users/mmiesch/modules
module use $OPT/modulefiles/core
module load jedi/intel19-impi
module list
module unload eckit  #in some cases, previous stored eckit may cause issues

#------------------------------------------------------------------------------#
# Debugging options
#------------------------------------------------------------------------------#

export OOPS_TRACE=0
export OOPS_DEBUG=0
export OOPS_LOG=0

#------------------------------------------------------------------------------#
# Other recommended options
#------------------------------------------------------------------------------#

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE

#------------------------------------------------------------------------------#
# Output directories
#------------------------------------------------------------------------------#
mkdir -p output
mkdir -p output/log
mkdir -p output/hofx

#------------------------------------------------------------------------------#
# Run
# Examples are provided for different observation types with use of different 
# QC (filters) and other features
# - Radiosonde
# - Aircraft
# - Satwinds
# - GnssroBnd
# - Amsua_n19
# - Atms_n20
# - Cris_n20
# Notes:
# For radiance, it is critical to set up the correct CoefficientPath in the yaml file. 
#------------------------------------------------------------------------------#

export instrument=Cris_n20
export application=gfs

#---------------
#Example: run radiosonde operator using fv3 background (no QC)
#---------------
srun --ntasks=12 --cpu_bind=core --distribution=block:block ../../build/bin/fv3jedi_hofx_nomodel.x config/${instrument}_${application}.hofx3d.jedi.yaml  output/log/log_3dhofx
