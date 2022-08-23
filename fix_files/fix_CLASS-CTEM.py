import xarray as xr
import numpy as np

### Read in file
fname = 'CLASS-CTEM_SF1_fFire.nc'
ds = xr.open_dataset('corrupted/'+fname)

### Define latitudes and longitudes
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

### Update latitudes and longitudes in DataSet
ds['y'] = lat
ds['x'] = lon

### Rename dimensions and coordinates
ds = ds.rename({'y': 'lat', 'x' : 'lon'})

### Set attributes
ds['fFire'].attrs={'units':'kg C m-2 s-1', 'long_name':'latitude'}
ds['lon'].attrs={'units':'degrees_east', 'long_name':'longitude'}
ds['lat'].attrs={'units':'degrees_north', 'long_name':'latitude'}

### Write to netCDF
ds.to_netcdf('raw/'+fname,
             encoding={'time':{'dtype': 'double'},
                       'lat':{'dtype': 'double'},
                       'lon':{'dtype': 'double'},
                       'fFire':{'dtype': 'float32'}})
