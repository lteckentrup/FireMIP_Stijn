### Model names
declare -a model_list=('CLASS-CTEM' 'CLM' 'Inferno' 'LPJ-GUESS-GlobFIRM'
                       'LPJ-GUESS-SIMFIRE-BLAZE' 'LPJ-GUESS-SPITFIRE' 
                       'ORCHIDEE-SPITFIRE')
                                              
### In raw_data: Check variable names, if fFire is total or per PFT, units
for model in "${model_list[@]}"; do
    echo ${model}
    cdo showvar ${model}_SF1_fFire.nc 
    cdo showlevel ${model}_SF1_fFire.nc 
    cdo showunit ${model}_SF1_fFire.nc 
done

### Harmonize variable and dimension names
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
         Inferno_SF1_fFire.nc
ncrename -v fFire.,fFire LPJ-GUESS-GlobFIRM_SF1_fFire.nc
ncrename -v Cfire.monthly,fFire LPJ-GUESS-SIMFIRE-BLAZE_SF1_fFire.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
         LPJ-GUESS-SPITFIRE_SF1_fFire.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
          ORCHIDEE-SPITFIRE_SF1_fFire.nc
          
### CLASS-CTEM, CLM, and LPJ-GUESS-SPITFIRE have corrupted netCDF structure:
python fix_CLASS_CTEM.py
python fix_CLM.py
python fix_LPJ-GUESS-SPITFIRE.py

### Sort grid for CLASS-CTEM and LPJ-GUESS-SPITFIRE
cdo -b F64 setgrid,grid_CLASS-CTEM.txt CLASS-CTEM_SF1_fFire.nc \
    ../raw/CLASS-CTEM_SF1_fFire.nc
cdo -b F64 remapycon,grid_LPJ-GUESS-SPITFIRE.txt LPJ-GUESS-SPITFIRE_SF1_fFire_coords.nc \
    ../raw/LPJ-GUESS-SPITFIRE_SF1_fFire.nc
    
### Select years 1901-2013, harmonize grid
for model in "${model_list[@]}"; do
    cdo -L -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 \
            raw/${model}_SF1_fFire.nc \
            native_grid/${model}_SF1_fFire.nc
done
