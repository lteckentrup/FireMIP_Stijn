### Define experiment: SF1, SF2_CO2, SF2_FPO, SF2_FLA, SF2_FLI or SF2_FCL
exp='SF1'
### Model names
if [ ${exp} = SF1 ] || [ ${exp} = SF2_CO2 ] || [ ${exp} = SF2_FLA ]; then
      declare -a model_list=('CLASS-CTEM' 'CLM' 'Inferno' 'JSBACH-SPITFIRE' 
                             'LPJ-GUESS-GlobFIRM' 'LPJ-GUESS-SIMFIRE-BLAZE' 
                             'LPJ-GUESS-SPITFIRE' 'ORCHIDEE-SPITFIRE')
elif [ ${exp} = SF2_FPO ] || [ ${exp} = SF2_FCL ]; then
       declare -a model_list=('CLASS-CTEM' 'CLM' 'Inferno' 'JSBACH-SPITFIRE' 
                              'LPJ-GUESS-SIMFIRE-BLAZE' 'LPJ-GUESS-SPITFIRE' 
                              'ORCHIDEE-SPITFIRE')
elif [ ${exp} = SF2_FLI ]; then
       declare -a model_list=('CLASS-CTEM' 'Inferno' 'JSBACH-SPITFIRE' 
                              'LPJ-GUESS-SPITFIRE' 'ORCHIDEE-SPITFIRE')    
fi
                          
### In raw_data: Check variable names, if fFire is total or per PFT, units
for model in "${model_list[@]}"; do
    echo ${model}
    cdo showvar raw/${model}_${exp}_fFire.nc
    cdo showlevel raw/${model}_${exp}_fFire.nc
    cdo showunit raw/${model}_${exp}_fFire.nc
    cdo showyear raw/${model}_${exp}_fFire.nc
done

### CLASS-CTEM, and CLM have corrupted netCDF structure:
python fix_CLASS_CTEM.py
python fix_CLM.py

### LPJ-GUESS-SPITFIRE is missing latitudes in the North and South with no land areas
cdo -b F64 remapycon,grid_LPJ-GUESS-SPITFIRE.txt \
       corrupted/LPJ-GUESS-SPITFIRE_${exp}_fFire.nc \
       raw/LPJ-GUESS-SPITFIRE_${exp}_fFire.nc

### Harmonize variable and dimension names
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
         raw/Inferno_${exp}_fFire.nc
ncatted -O -a units,'fFire',o,c,'kg C m-2 s-1' raw/JSBACH-SPITFIRE_${exp}_fFire.nc       
ncrename -v fFire.,fFire raw/LPJ-GUESS-GlobFIRM_${exp}_fFire.nc
ncrename -v Cfire.monthly,fFire raw/LPJ-GUESS-SIMFIRE-BLAZE_${exp}_fFire.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
          raw/ORCHIDEE-SPITFIRE_${exp}_fFire.nc
              
### Select years 1901-2013, harmonize grid
for model in "${model_list[@]}"; do
    echo ${model}
    cdo -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 \
         raw/${model}_${exp}_fFire.nc \
         native_grid/${model}_${exp}_fFire.nc
done

### Convert gridded files to total annual fire CO2 emissions. Output unit: PgC yr-1

for model in "${model_list[@]}"; do
    ### LPJ-GUESS-GlobFIRM only has annual fire CO2 emissions
    if [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
        cdo -L -b F64 -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                      -chunit,'kg C m-2 s-1','PgC yr-1'\
                      native_grid/${model}_${exp}_fFire.nc -gridarea \
                      native_grid/${model}_${exp}_fFire.nc \
                      native_grid/${model}_${exp}_fFire_annual_global.nc
    else
        cdo -L -b F64 -yearsum -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                      -chunit,'kg C m-2 s-1','PgC yr-1'\
                      native_grid/${model}_${exp}_fFire.nc -gridarea \
                      native_grid/${model}_${exp}_fFire.nc \
                      native_grid/${model}_${exp}_fFire_annual_global.nc
    fi
done

#### Regrid all models on coarsest grid: Target CLASS-CTEM
for model in "${model_list[@]}"; do
    if [ ${model} = CLASS-CTEM ] ; then
         cp native_grid/${model}_${exp}_fFire.nc \
            coarse_grid/${model}_${exp}_fFire.nc
    else
         cdo -L -b F64 -remapycon,coarse_grid.txt \
             native_grid/${model}_${exp}_fFire.nc \
             coarse_grid/${model}_${exp}_fFire.nc
    fi
done

#### Regrid all models on finest grid: Target LPJ-GUESS. 
### ORCHIDEE also has a half degree grid
for model in "${model_list[@]}"; do
    if [ ${model} = LPJ-GUESS-SPITFIRE ]; then
         cdo -b F64 invertlat native_grid/${model}_${exp}_fFire.nc \
                              fine_grid/${model}_${exp}_fFire.nc
    elif [ ${model} = LPJ-GUESS-GlobFIRM ]; then
         cp native_grid/${model}_${exp}_fFire.nc \
            fine_grid/${model}_${exp}_fFire_annual.nc
    elif [ ${model} = LPJ-GUESS-SIMFIRE-BLAZE ]; then 
         cdo -L -b F64 setgrid,fine_grid.txt \
             native_grid/${model}_${exp}_fFire.nc \
             fine_grid/${model}_${exp}_fFire.nc
    elif [ ${model} = ORCHIDEE-SPITFIRE ]; then
           cp native_grid/${model}_${exp}_fFire.nc \
              fine_grid/${model}_${exp}_fFire.nc
    else
         cdo -L -b F64 -remapycon,fine_grid.txt \
             native_grid/${model}_${exp}_fFire.nc \
             fine_grid/${model}_${exp}_fFire.nc
    fi
done

### Calculate annual and annual global fire CO2 emissions
for grid_res in native coarse fine; do
    for model in "${model_list[@]}"; do
        ### LPJ-GUESS-GlobFIRM only has annual fire CO2 emissions
        if [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
            cdo -L -b F64 -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                          -chunit,'kg C m-2 s-1','PgC yr-1'\
                          ${grid_res}_grid/${model}_${exp}_fFire.nc -gridarea \
                          ${grid_res}_grid/${model}_${exp}_fFire.nc \
                          ${grid_res}_grid/${model}_${exp}_fFire_annual_global.nc
        else
            cdo -L -b F64 -yearsum ${grid_res}_grid/${model}_${exp}_fFire.nc \
                          ${grid_res}_grid/${model}_${exp}_fFire_annual.nc
            cdo -L -b F64 -yearsum -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                          -chunit,'kg C m-2 s-1','PgC yr-1'\
                          ${grid_res}_grid/${model}_${exp}_fFire.nc -gridarea \
                          ${grid_res}_grid/${model}_${exp}_fFire.nc \
                          ${grid_res}_grid/${model}_${exp}_fFire_annual_global.nc
        fi
    done
done
