import xarray as xr
import numpy as np

### Read in file
ds = xr.open_dataset('corrupted/LPJ-GUESS-SPITFIRE_SF1_fFire.nc')

### Generate values for latitudes and longitudes
lat = np.arange(-55.75,83.25,0.5)
lon = np.arange(-179.75,180.25,0.5)

### Replace values in dataset with values from above
ds['lat'] = lat
ds['lon'] = lon

### Get DataArray
da = ds.fFire

da.time.encoding['units'] = 'Seconds since 1850-01-01 00:00:00'
da.time.encoding['long_name'] = 'time'
da.time.encoding['calendar'] = '365_day'

da['lat'].attrs={'units':'degrees', 'long_name':'latitude'}
da['lon'].attrs={'units':'degrees', 'long_name':'longitude'}

da.attrs['Source_Format'] = 'LPJ-GUESS-SPITFIRE'
da.attrs['Name'] = 'SF1'
da.attrs['Forcing_data'] = 'CRUNCEP'
da.attrs['Contact'] = 'matthew.forrest@senckenberg.de'
da.attrs['Institute'] = 'Senckenberg BiK-F'
da.attrs['DGVMData_quant'] = 'fFire'

### Convert DataArray to DataSet
ds = da.to_dataset()

### Write to netCDF
ds = ds.to_netcdf('corrupted/LPJ-GUESS-SPITFIRE_SF1_fFire_coords.nc',
                   encoding={'time':{'dtype': 'double'},
                   'lat':{'dtype': 'double'},
                   'lon':{'dtype': 'double'},
                   'fFire':{'dtype': 'float32'}})
