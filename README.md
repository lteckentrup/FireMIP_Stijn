# FireMIP_Stijn

1. Rename all files in a consistent way: ```<model>_<experiment>_<variable>.nc```. Experiment names: SF1, SF2_CO2, SF2_FPO, SF2_FLA, SF2_FLI, and SF2_FCL.
2. For each experiment: Move CLASS-CTEM, CLM, and LPJ-GUESS-SPITFIRE into 'corrupted' directory
3. Move remaining models into 'raw' directory
4. Create ```native_grid```, ```fine_grid```, and ```coarse_grid``` directory
5. For fire CO2 emissions, run ```sh harmonise_fFire.sh```
6. For burnt area, run ```sh harmonise_BA.sh```

Both shell scripts adjust all files so that variable, unit, dimensions names and the North-South orientation are the same. They also regrid all files on a common coarse grid (target: CLASS-CTEM) or a common fine grid (target: LPJ-GUESS and ORCHIDEE). The target grid files are stored in

```coarse_grid.txt```
and
```fine_grid.txt```

The output files are monthly fire CO2 emissions (kg C m-2 s-1) and monthly burnt area fraction (%). LPJ-GUESS-GlobFirm only has annual output for both. Files with the suffix ```_annual.nc``` are gridded files aggregated to annual values. Files with the suffix ```_annual_global.nc``` are area weighted annual averages (burnt area fraction) and sums (fire CO2 emissions; unit: PgC yr-1). Files with the suffix ```_annual_global_Mha.nc``` are area weighted annual sums of burnt area in mega hectare per year.
