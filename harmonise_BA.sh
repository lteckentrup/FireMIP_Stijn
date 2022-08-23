### Experiment
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

for model in JSBACH-SPITFIRE ORCHIDEE-SPITFIRE; do
    cdo -b F64 vertsum burntArea/${model}_${exp}_burntArea.nc \
                       raw/${model}_${exp}_BA.nc
done

### Inferno has burnt area fraction per day
cdo -b F64 -chname,burntArea,BA -vertsum -setrtoc,-10,0,0 -mulc,365 -mulc,86400 \
     burntArea/Inferno_${exp}_burntArea.nc \
     raw/Inferno_${exp}_BA.nc

ncatted -a units,'BA',c,c,'%' raw/Inferno_${exp}_BA.nc

### CLM has corrupted netCDF structure:
python fix_CLASS_CTEM.py
python fix_CLM.py

### LPJ-GUESS-SPITFIRE is missing latitudes in the North and South with no land areas
cdo -b F64 remapycon,grid_LPJ-GUESS-SPITFIRE.txt \
       corrupted/LPJ-GUESS-SPITFIRE_${exp}_BA.nc \
       raw/LPJ-GUESS-SPITFIRE_${exp}_BA.nc

### Harmonize variable and dimension names
ncrename -v longitude,lon -v latitude,lat raw/CLASS-CTEM_${exp}_BA.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
         raw/Inferno_${exp}_BA.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
        -v burntArea,BA raw/JSBACH-SPITFIRE_${exp}_BA.nc
ncrename -v burntArea.,BA raw/LPJ-GUESS-GlobFIRM_${exp}_BA.nc
ncrename -v BA.,BA raw/LPJ-GUESS-SIMFIRE-BLAZE_${exp}_BA.nc
ncrename -v longitude,lon -v latitude,lat -d longitude,lon -d latitude,lat \
         -v burntArea,BA raw/ORCHIDEE-SPITFIRE_${exp}_BA.nc

### In raw_data: Check whether variablenames, unit names, number of years,
### and number of levels match
for model in "${model_list[@]}"; do
    echo ${model}
    cdo showvar raw/${model}_${exp}_BA.nc
    cdo showlevel raw/${model}_${exp}_BA.nc
    cdo showunit raw/${model}_${exp}_BA.nc
    cdo showyear raw/${model}_${exp}_BA.nc
done

### Select years 1901-2013, harmonize grid
for model in "${model_list[@]}"; do
    echo ${model}
    if [ ${model} == JSBACH-SPITFIRE ]; then
         cdo -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 -muldpm \
              raw/${model}_${exp}_BA.nc \
              native_grid/${model}_${exp}_BA.nc
    elif [ ${model} == ORCHIDEE-SPITFIRE ]; then
           cdo -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 -muldpm -invertlat \
                raw/${model}_${exp}_BA.nc \
                native_grid/${model}_${exp}_BA.nc
    elif [ ${model} == LPJ-GUESS-GlobFIRM ]; then
         cdo -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 \
              raw/${model}_${exp}_BA.nc \
              native_grid/${model}_${exp}_BA_annual.nc
    else
         cdo -sellonlatbox,-180,180,-90,90 -selyear,1901/2013 \
              raw/${model}_${exp}_BA.nc \
              native_grid/${model}_${exp}_BA.nc
    fi
done

#### Regrid all models on coarsest grid: Target CLASS-CTEM
for model in "${model_list[@]}"; do
    if [ ${model} = CLASS-CTEM ] ; then
         cp native_grid/${model}_${exp}_BA.nc \
            coarse_grid/${model}_${exp}_BA.nc
    elif [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
        cdo -L -b F64 -remapycon,coarse_grid.txt \
            native_grid/${model}_${exp}_BA_annual.nc \
            coarse_grid/${model}_${exp}_BA_annual.nc
    else
         cdo -L -b F64 -remapycon,coarse_grid.txt \
             native_grid/${model}_${exp}_BA.nc \
             coarse_grid/${model}_${exp}_BA.nc
    fi
done

### Regrid all models on finest grid: Target LPJ-GUESS.
### ORCHIDEE also has a half degree grid
for model in "${model_list[@]}"; do
    if [ ${model} = LPJ-GUESS-GlobFIRM ]; then
         cp native_grid/${model}_${exp}_BA_annual.nc \
            fine_grid/${model}_${exp}_BA_annual.nc
    elif [ ${model} = LPJ-GUESS-SIMFIRE-BLAZE ]; then
         cdo -L -b F64 setgrid,fine_grid.txt \
             native_grid/${model}_${exp}_BA.nc \
             fine_grid/${model}_${exp}_BA.nc
    elif [ ${model} = LPJ-GUESS-SPITFIRE ] || [ ${model} = ORCHIDEE-SPITFIRE ]; then
           cp native_grid/${model}_${exp}_BA.nc \
              fine_grid/${model}_${exp}_BA.nc
    else
         cdo -L -b F64 -remapycon,fine_grid.txt \
             native_grid/${model}_${exp}_BA.nc \
             fine_grid/${model}_${exp}_BA.nc
    fi
done

### Calculate annual and annual global burnt area fraction
for grid_res in native coarse fine; do
    for model in "${model_list[@]}"; do
        ### LPJ-GUESS-GlobFIRM only has annual fire CO2 emissions
        if [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
            cdo -L -b F64 fldmean \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc \
                          ${grid_res}_grid/${model}_${exp}_BA_annual_global.nc
        else
            ### LPJ-GUESS_SPITFIRE and ORCHIDEE-SPITFIRE get values greater than 100%
            cdo -L -b F64 -setrtoc,100,10000,100 -yearsum \
                          ${grid_res}_grid/${model}_${exp}_BA.nc \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc
            cdo -L -b F64 -fldmean -setrtoc,100,10000,100 -yearsum  \
                          ${grid_res}_grid/${model}_${exp}_BA.nc \
                          ${grid_res}_grid/${model}_${exp}_BA_annual_global.nc
        fi
    done
done

### Calculate total annual global burnt area [Mha yr-1]
for grid_res in native coarse fine; do
    for model in "${model_list[@]}"; do
        ### LPJ-GUESS-GlobFIRM only has annual fire CO2 emissions
        if [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
            cdo -L -b F64 -divc,1e+10 -fldsum -chunit,'%','Mha yr-1' -divc,100 -mul \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc -gridarea \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc \
                          ${grid_res}_grid/${model}_${exp}_BA_annual_global_Mha.nc
        else
            cdo -L -b F64 -divc,1e+10 -fldsum -chunit,'%','Mha yr-1' -divc,100  -mul \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc -gridarea \
                          ${grid_res}_grid/${model}_${exp}_BA_annual.nc \
                          ${grid_res}_grid/${model}_${exp}_BA_annual_global_Mha.nc
        fi
    done
done
