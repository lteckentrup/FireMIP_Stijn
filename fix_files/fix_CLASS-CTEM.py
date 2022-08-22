import xarray as xr
import numpy as np

### Read in file
fname = 'CLASS-CTEM_SF1_fFire.nc'
ds = xr.open_dataset('corrupted/'+fname)

### Get data
fFire = ds.fFire
time = ds.time
lat = [-87.8638, -85.09653, -82.31291, -79.5256, -76.7369, -73.94752, -71.15775,
       -68.36776, -65.57761, -62.78735, -59.99702, -57.20663, -54.4162,
       -51.62573, -48.83524, -46.04473, -43.2542, -40.46365, -37.67309,
       -34.88252, -32.09195, -29.30136, -26.51077, -23.72017, -20.92957,
       -18.13897, -15.34836, -12.55776, -9.767145, -6.976533, -4.18592,
       -1.395307, 1.395307, 4.18592, 6.976533, 9.767145, 12.55776, 15.34836,
       18.13897, 20.92957, 23.72017, 26.51077, 29.30136, 32.09195, 34.88252,
       37.67309, 40.46365, 43.2542, 46.04473, 48.83524, 51.62573, 54.4162,
       57.20663, 59.99702, 62.78735, 65.57761, 68.36776, 71.15775, 73.94752,
       76.7369, 79.5256, 82.31291, 85.09653, 87.8638]
lon = np.arange(0,360,360/len(ds.x))

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
ds.to_netcdf('raw/'+fname,
             encoding={'time':{'dtype': 'double'},
                       'lat':{'dtype': 'double'},
                       'lon':{'dtype': 'double'},
                       'fFire':{'dtype': 'float32'}})
