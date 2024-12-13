# TCADtoPixelAV
Tools to create/modify TCAD output files as input files to PixelAV


## Introduction
PixelAV is a simulation tool with many uses, one of which is to simulate the induced charge (as a function of time) in a pixel sensor array for an incident pion with a defined incident angle and momentum. In order to perform these simulations, PixelAV needs information on the electric fields and weighting fields of these sensors, which can be produced using an FEM software. DF-ISE TCAD was used for this purpose in the past for which the simulation results have been verified and accepted. Currently, there is interest in simulating the same using Silvaco TCAD and Sentaurus Synopsis. Since the formats involved with Silvaco are slightly different, codes to modify the simulation framework (DF-ISE + PixelAV) to use Silvaco (Silvaco + PixelAV) instead of DF-ISE are needed and are what is stored in this repository. The simulation framework cycle will look like the following:
Silvaco TCAD simulation -> Parsers (exports silvaco data and converts to a format readable by interpolation codes) -> Interpolation + Alteration (converts to a format required by PixelAV) -> PixelAV simulation.

## Parsers
The original author of the scripts to extract data from Silvaco was motivated from [this](https://docs.google.com/document/d/1_cMVVW3Z-kzEkRnzKBCPwtvXYCGjXNB8bO0RWyMA2pk/edit) file and credits go to Marco Bomben. These scripts were modified to suit the Silvaco software versions at UIC. More info on code-runs are present in [script.sh].

## Interpolation, alteration and PixelAV simulation
These functionalities are being performed by codes written by Morris Swartz, JHU.
```
export PATH=$PATH:/location/to/PixelAV/recipes_c-ansi/lib/
gcc gen_efield.c -o gen_efield -I ./recipes_c-ansi/include/ -I ./recipes_c-ansi/lib/ -I ./recipes_c-ansi/recipes/ ./recipes_c-ansi/lib/librecipes_c.a -lm
./gen_efield silvaco50x13 100
```
Store the relevant files in a folder name ABC with the TCAD result files in the format ABC_msh.grd and ABC_XYZ_des.dat where XYZ is the bias voltage. While running the complied code pass the folder name (ABC) and bias voltage (XYZ). IN the above example, 100 is the chosen bias voltage. 

Note 1: You might have to change the NSTACK size and array initialization size based on the no. of vertices your TCAD data has. I also commented on the plotting part of the code as it looked for fields from specific points in the midplane.

Note 2: recipes_c-ansi needs to be compiled and built: change LIBDIR (line 21) in Makefile to lib/, a folder you will create in recipes_c-ansi. Then remove the comment on the first line of the file "airy.c" in recipes_c-ansi/recipes/. Finally, run make. (I also had to change gnumake to make).

Once the interpolation is done, make sure to the relevant header file before running PixelAV.

Example output for gen_efield:
```
user@user silvaco_datagen % ./gen_efield silvaco50x13 100
Grid file = silvaco50x13/silvaco50x13_msh.grd, dessis plot file = silvaco50x13/silvaco50x13_100_des.dat
number of vertices = 47652
detector dimensions = 25.000000 6.250000 100.000000 um 
field = 441.889000 433.236000 -16.666500 V/cm 
enter the number of output grid points in each dim: nx[21], ny[21], nz[92]
26 13 51
(nx, ny, nz) = (26, 13, 51)
total Lorentz Drift = 0.000000, average efield = nan 
enter zmin (E = 0 for z>zmin) 
100
zmin = 100.000000 um
```

## Validation plots
There are two primary stages of data production: (1) massaged TCAD results and (2) PixelAV. 
1. Massaged TCAD results correspond to the slice-creation, extraction, and merging of TCAD data. This final massaged TCAD data is compared with the DF-ISE TCAD data using [validateSilvacoData.py].
2. Inorder to validate the simulation results from the Silvaco+PixelAV framework, a comparison of results from Silvaco+PixelAV with DF-ISE involving the same sensor structure and simulations, needs to be done. [validatePixelAVData.py] is the python file that performs this task.
