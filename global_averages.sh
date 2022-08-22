### Model names
declare -a model_list=('CLASS-CTEM' 'CLM' 'Inferno' 'LPJ-GUESS-GlobFIRM'
                       'LPJ-GUESS-SIMFIRE-BLAZE' 'LPJ-GUESS-SPITFIRE' 
                       'ORCHIDEE-SPITFIRE')
                     
### Convert gridded files to total annual fire CO2 emissions. Output unit: PgC yr-1

for model in "${model_list[@]}"; do
    ### LPJ-GUESS-GlobFIRM only has annual fire CO2 emissions
    if [ ${model} = LPJ-GUESS-GlobFIRM ] ; then
        cdo -L -b F64 -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                      -chunit,'kg C m-2 s-1','PgC yr-1'\
                      native_grid/${model}_SF1_fFire.nc -gridarea \
                      native_grid/${model}_SF1_fFire.nc \
                      native_grid/${model}_SF1_fFire_annual_global.nc   
    else
        cdo -L -b F64 -yearsum -fldsum -divc,1e+12 -mulc,86400 -muldpm -mul \
                      -chunit,'kg C m-2 s-1','PgC yr-1'\
                      native_grid/${model}_SF1_fFire.nc -gridarea \
                      native_grid/${model}_SF1_fFire.nc \
                      native_grid/${model}_SF1_fFire_annual_global.nc  
    fi 
done
