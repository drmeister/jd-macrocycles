#!/bin/bash

#PBS -N H045_build.pf
#PBS -o H045_build.out
#PBS -q normal
#PBS -l nodes=1:ppn=12
#PBS -l walltime=6:00:00
#PBS

cd $PBS_O_WORKDIR

./runme.sh
