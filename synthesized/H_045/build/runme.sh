#!/bin/bash

# -s N -t C
# prep files and run allsteps
for i in EPR; do
    cd $i
    python ~/research/repos/scripts/Allsteps_VAV.py $i.mol2 $i CappingAtoms.dat X G 0 &> allsteps.log # runs allsteps
    cd ..; done

mkdir tmp; cp EPR/EPR.off tmp
cp NIB/NIB.off tmp;
cd tmp

    # Build tleap script.
echo source leaprc.gaff >> build.tleap
echo gaff = loadamberparams gaff.dat >> build.tleap
echo loadoff NIB.off >> build.tleap
echo loadoff EPR.off >> build.tleap
echo H045 = sequence { NIB EPR NIB EPR NIB EPR } >> build.tleap
echo bond H045.1.N H045.6.C >> build.tleap
echo saveAmberParm H045 H045.prmtop H045.crd >> build.tleap
echo quit >> build.tleap

    # Run the tleap script
tleap -f build.tleap

    # Run Acpype
python ~/research/scripts/acpype.py -p H045.prmtop -x H045.crd -b H045
cd ..
