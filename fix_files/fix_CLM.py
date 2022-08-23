import xarray as xr
import numpy as np
import pandas as pd

### Read in file
fname = 'CLM_SF1_fFire.nc'
ds = xr.open_dataset('corrupted/'+fname)

### Get data
fFire = ds.transpose('time','lat','lon').CFFIRE
time = pd.date_range(start='1850-01-01',
                     end='2013-12-31',
                     freq='M')

lat = ds.lat
lon = ds.lon

### Create DataArray
da = xr.DataArray(
    fFire,
    dims=('time', 'lat', 'lon'),
    coords={'time': time, 'lat': lat, 'lon': lon},
    attrs={'units': 'kg C m-2 s-1',
           'long_name': 'CO2_emission_from_fire'}
)

da.time.encoding['units'] = 'Months since 1850-01-01 00:00:00'
da.time.encoding['long_name'] = 'time'
da.time.encoding['calendar'] = '365_day'

da['lat'].attrs={'units':'degrees_north', 'long_name':'latitude'}
da['lon'].attrs={'units':'degrees_east', 'long_name':'longitude'}

ds = da.to_dataset(name='fFire')
ds.to_netcdf('raw/'+fname,
             encoding={'time':{'dtype': 'double'},
                       'lat':{'dtype': 'double'},
                       'lon':{'dtype': 'double'},
                       'fFire':{'dtype': 'float32'}})
