#!/usr/bin/bash
#SBATCH --job-name=runhofx
#SBATCH --time=00:29:00
#SBATCH --partition=s4
#SBATCH --ntasks=12
#SBATCH --cpus-per-task=1
#SBATCH --account=jcsda

source /etc/bashrc
module purge
export OPT=/data/users/mmiesch/modules
module use /data/users/mmiesch/modules/modulefiles/core
module load jedi/intel19-impi
module list
module unload eckit
ulimit -s unlimited

export SLURM_EXPORT_ENV=ALL
export HDF5_USE_FILE_LOCKING=FALSE
export OOPS_TRACE=0
export OOPS_DEBUG=0
export OOPS_LOG=0

mkdir -p output
mkdir -p output/log
mkdir -p output/hofx

#srun --ntasks=12 --cpu_bind=core --distribution=block:block /data/users/hshao/JEDI_public/fv3-bundle/build/bin/fv3jedi_hofx_nomodel.x config/GnssroBnd_gdas.hofx3d.jedi.yaml  output/log/log_3dhofx
srun --ntasks=12 --cpu_bind=core --distribution=block:block ../../build/bin/fv3jedi_hofx_nomodel.x config/GnssroBnd_gdas.hofx3d.jedi.yaml  output/log/log_3dhofx
