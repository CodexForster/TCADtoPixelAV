# ========================
# ELECTRIC FIELD GEN - FST
# ========================
cd xy_extract
python3 extract-2D.py --template template_E_Field_Z.set --set  cutZ_ --TwoDname map2Dz_ --ThreeDname ../cmsPixel_50x13_postBias_-100V.str --zmin 0 --zmax 6.25 --step 0.1 > allCuts.txt
# check if the ELEV value in cutZ_i has the correct sign. Can differ in tonyplot versions.
source allCuts.txt
# Edit loop_Ei.in depending on the number of cuts
deckbuild -run loop_Ex.in -outfile loop_Ex.out &
deckbuild -run loop_Ey.in -outfile loop_Ey.out &
deckbuild -run loop_Ez.in -outfile loop_Ez.out &
python3 create-3D-map.py --prefix map2Dz_ --suffix _EFieldX.dat --outputname E_FieldX.dat --zmin 0 --zmax 6.25 --step 0.1
python3 create-3D-map.py --prefix map2Dz_ --suffix _EFieldY.dat --outputname E_FieldY.dat --zmin 0 --zmax 6.25 --step 0.1
python3 create-3D-map.py --prefix map2Dz_ --suffix _EFieldZ.dat --outputname E_FieldZ.dat --zmin 0 --zmax 6.25 --step 0.1
# important to pass inputs in this order
python3 merge_maps.py --output EField_YX.txt --input E_FieldX.dat E_FieldY.dat E_FieldZ.dat

python3 extract-2D.py --template template_E_Field_X.set --set  cutX_ --TwoDname map2Dx_ --ThreeDname ../cmsPixel_50x13_postBias_-100V.str --zmin 0 --zmax 25 --step 0.5 > allCuts.txt
source allCuts.txt
# Edit loop_Ei.in depending on the number of cuts
deckbuild -run loop_Ex.in -outfile loop_Ex.out &
deckbuild -run loop_Ey.in -outfile loop_Ey.out &
deckbuild -run loop_Ez.in -outfile loop_Ez.out &
python3 create-3D-map.py --prefix map2Dx_ --suffix _EFieldX.dat --outputname E_FieldX.dat --zmin 0 --zmax 25 --step 0.5
python3 create-3D-map.py --prefix map2Dx_ --suffix _EFieldY.dat --outputname E_FieldY.dat --zmin 0 --zmax 25 --step 0.5
python3 create-3D-map.py --prefix map2Dx_ --suffix _EFieldZ.dat --outputname E_FieldZ.dat --zmin 0 --zmax 25 --step 0.5
# important to pass inputs in this order
python3 merge_maps.py --output EField_YZ.txt --input E_FieldX.dat E_FieldY.dat E_FieldZ.dat

# gen final efield & grid files from silvaco data
# EField_YX.txt and EField_YZ.txt are generated from the prev steps and should be stored in prodname folder
python3 gen_gridAndFieldFile.py --prodname silvaco50x13
# Validation - copy the relecant mesh and wgt_pot files (Raw data, no header files) to validation folder
python3 validation/validateSilvacoData.py -e

# ========================
# WEIGHTING POTENTIAL GEN - FST
# ========================
cp ./cmsPixel_postBias_1V.str ./extract/
python3 extract-2D.py --template template_E_Field_Z.set --set  cutZ_ --TwoDname map2Dz_ --ThreeDname ../cmsPixel_postBias_1V.str --zmin 0 --zmax 31.25 --step 1 > allCuts.txt
# check if the ELEV value in cutZ_i has the correct sign. Can differ in tonyplot versions.
source allCuts.txt
# Edit loop_Ex.in depending on the number of cuts
deckbuild -run loop_Ex.in -outfile loop_Ex.out &
python3 create-3D-map.py --prefix map2Dz_ --suffix _Potential.dat --outputname Potential_YX.dat --zmin 0 --zmax 31.25 --step 1
# copy to prodname folder
cp ./Potential_YX.dat ../../Potential_YX.dat
# Potential_YX.txt is generated from the prev step and should be stored in prodname folder
python3 gen_wgtpotGridAndPotFile.py --prodname silvaco50x13wgt
# check if the last five coordinates and potential values match
# Validation - copy the relecant mesh and wgt_pot files (Raw data, no header files) to validation folder
python3 validateSilvacoData.py -w

# ========================
# PIXELAV DATA GEN
# ========================
# Edit the pixelav code with the correct mesh size
ln -s ./dot1_50x13_phase3_100v_263k.init ppixel2.init
ln -s ./weighting_BPix_50x13x100.init wgt_pot.init
./linkx64_icx ppixelav2_list_trkpy_n_2f
python3 job_submit.py | tee output.txt

# OR
./linkx64_icx ppixelav2_list_trkpy_n_2f
./ppixelav2_list_trkpy_n_2f 1

# OR
gcc -c ppixelav2_list_trkpy_n_2f.c
gcc -o pixelavrun ppixelav2_list_trkpy_n_2f.o -lm
./pixelavrun 