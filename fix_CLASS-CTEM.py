import xarray as xr
import numpy as np

### Read in file
fname = 'CLASS-CTEM_SF1_fFire.nc'
ds = xr.open_dataset('corrupted/'+fname)

### Get data
fFire = ds.fFire
time = ds.time
lat = np.arange(-90,90,180/len(ds.y))
lon = np.arange(-180,180,360/len(ds.x))

### Create DataArray
da = xr.DataArray(
    fFire,  
    dims=('time', 'lat', 'lon'),
    coords={'time': time, 'lat': lat, 'lon': lon},
    attrs={'units': 'kgC/m^2/s',
           'long_name': 'CO2_emission_from_fire',
           'Title': 'CLASS-CTEM output generated for 2016 FireMIP',
           'Comment': 'Note the PFT 10 is bare ground',
           'Contact': 'Joe Melton, joe.melton@canada.ca',
           'code_id': '1f5a65728aa0bf6c3b30f5ca907de90a7aa47be0'}
)

da.time.encoding['units'] = 'Months since 1861-01-01 00:00:00'
da.time.encoding['long_name'] = 'time'
da.time.encoding['calendar'] = '365_day'

da['lat'].attrs={'units':'degrees', 'long_name':'latitude'}
da['lon'].attrs={'units':'degrees', 'long_name':'longitude'}

ds = da.to_dataset()
ds.to_netcdf(fname,
             encoding={'time':{'dtype': 'double'},
                       'lat':{'dtype': 'double'},
                       'lon':{'dtype': 'double'},
                       'fFire':{'dtype': 'float32'}})

