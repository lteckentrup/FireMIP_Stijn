# FireMIP_Stijn

1. Rename all files in consistent ways: <model>_<experiment>_<variable>.nc
2. For each experiment: Move CLASS-CTEM, CLM, and LPJ-GUESS-SPITFIRE into 'corrupted' directory
3. Move remaining models into 'raw' directory
4. Create native_grid, fine_grid, and coarse_grid directory
5. For fire CO2 emissions, run sh harmonise_fFire.sh
6. For burnt area, run sh harmonise_BA.sh

Both shell scripts adjust all files so that variable, unit, and dimensions names are the same. They also regrid all files on a common coarse grid (target: CLASS-CTEM) or a common fine grid (target: LPJ-GUESS and ORCHIDEE).
