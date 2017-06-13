#!/bin/bash

#PBS -N G182_prod6.pf
#PBS -o G182_prod6.out
#PBS -q normal
#PBS -l nodes=1:ppn=12
#PBS -l walltime=12:00:00
#PBS

cd $PBS_O_WORKDIR

. /home/tue91994/Programs/gromacs-5.0.4-installed/bin/GMXRC

module load openmpi

mpirun -np 12 mdrun_mpi -s prod6.tpr
