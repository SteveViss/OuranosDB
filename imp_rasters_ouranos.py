import os
import h5py as h5
import numpy as np
import re
import pandas as pd
import psycopg2 as pg
import logging
import time
import sys
from osgeo import gdal
from osgeo import gdal_array
from osgeo import osr


####################################
# FUNCTIONS
####################################

def cur_datetime(opt):
	current_time = time.localtime()
	if opt == 'fulldatetime': 
		return time.strftime('%Y-%m-%dT%H:%M:%S', current_time)
	elif opt == 'date':
		return time.strftime('%Y-%m-%d', current_time)
	else :
		logging.error('cur_datetime(): opt argument is unspecified...')
		sys.exit(1)


def import_h5( h5folder, name_h5file ):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	try:
		hfile = h5.File(h5folder+name_h5file,'r')
		return hfile

	except:
		logging.error('import_h5(): Could not open HDF5 file')
		sys.exit(1)


def get_model_h5files (h5folder , group_model):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	group_h5files = [f for f in os.listdir('./'+ h5folder) if os.path.isfile(os.path.join(h5folder,f)) and group_model in f]

	df_group_h5file = pd.DataFrame({'name': group_h5files,'region': [int(elem[:2]) for elem in group_h5files ]})
	df_group_h5file = df_group_h5file.sort(['region'])
	df_group_h5file.index = range(0,len(df_group_h5file))

	return df_group_h5file



def get_cells_bounds_pred( hfile, out = False):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	bound_grids = hfile['out']['grid']['BoundingBox']
	ls_bound = []

	for i in range(0,bound_grids.size):
		new_row = hfile[hfile['out']['grid']['BoundingBox'][0,i]]
		dict_row = {'lon_min': new_row[0,0],'lon_max': new_row[0,1],'lat_min': new_row[1,0],'lat_max': new_row[1,1]}
		ls_bound.append(dict_row)


	if out == True:
		df_bound = pd.DataFrame(ls_bound)
		df_bound.to_csv("out_files/"+h5file.replace(".mat","_bound.csv"),index=False)

	return ls_bound



def get_cells_centroid_pred( hfile , out = False):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""
	
	ls_centroid = []
	nCells = hfile['out']['grid']['X1'][:].size

	for i in range(0,nCells):
		lon_centroids = hfile[hfile['out']['grid']['X1'][0,i]][0,0]
		lat_centroids = hfile[hfile['out']['grid']['Y1'][0,i]][0,0]
		dict_row = {'lon': lon_centroids,'lat': lat_centroids}
		ls_centroid.append(dict_row)


	if out == True:
		df_centroid = pd.DataFrame(ls_centroid)
		df_centroid.to_csv("out_files/"+h5file.replace(".mat","_centroid.csv"),index=False)

	return ls_centroid


def get_dates_pred( hfile , metadata,ndataset):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	hdf_path_dates = "/".join(['out',metadata['scale_meth'],metadata['period'],'pr','dates'])

	ls_fulldate = []

	dataset_dates_yr = hfile[hfile[hdf_path_dates][ndataset,0]][0,...].astype(int)
	dataset_dates_month = hfile[hfile[hdf_path_dates][ndataset,0]][1,...].astype(int)
	dataset_dates_day = hfile[hfile[hdf_path_dates][ndataset,0]][2,...].astype(int)


	for date in range(0,len(dataset_dates_day)):
		year = dataset_dates_yr[date].astype(str)
		month = dataset_dates_month[date].astype(str)
		day = dataset_dates_day[date].astype(str)

		if len(month) == 1:
			month = '0' + month
		if len(day) == 1:
			day = '0' + day

		date = "-".join([year,month,day])
		ls_fulldate.append(date)

	return ls_fulldate

def get_clim_var_pred( hfile , metadata, date, ndataset):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""
	hdf_path_data = "/".join(['out',metadata['scale_meth'],metadata['period'],metadata['climvar'],'data'])

	ls_climvar = []

	dataset_clim_date = hfile[hfile[hdf_path_data][ndataset,0]][...,dat].astype(float)
		
	for n in range(0,len(dataset_clim_date)):
		ls_climvar.append(dataset_clim_date[n])

	return ls_climvar

def get_write_del_doublons(dict_out_climvars,delete=True):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	dict_dup_climvars = {'pr':pd.DataFrame(),'tasmin':pd.DataFrame(),'tasmax':pd.DataFrame()}

	for item in dict_out_climvars:
		dict_dup_climvars[item] = dict_out_climvars[item][dict_out_climvars[item].duplicated(['lat','lon'])]

		if not dict_dup_climvars[item].empty:
			dict_dup_climvars[item].to_csv("out_files/"+model+"_doublons_"+item+".csv",index=False)

		if delete == True:
			dict_dup_climvars[item] = dict_out_climvars[item].drop_duplicates(['lat','lon'])

def get_model_mdata(hfile,metadata):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	desc_model =  filter(None,re.split('-',"".join([chr(item) for item in hfile['out']['model']])))

	metadata['model_ipcc'] = desc_model[0]
	metadata['scenario_ipcc']  = desc_model[1]
	metadata['run_ipcc'] = desc_model[2]
	metadata['mod_code_ouranos'] = re.split('-|_',model)[0]


###############################################################################

logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',filename=cur_datetime('fulldatetime')+'_import_h5.log',level=logging.DEBUG, datefmt='%m/%d/%Y %I:%M:%S %p')

####################################
# PROGRAM
####################################

# Setup wd
os.chdir("/home/steve/Documents/GitHub/OuranosDB/")

# VARIABLES
h5folder= 'mat_files/'
model = 'gcm1_cccma_cgcm3_1-sresa1b-run1' # for loop
ls_climvars = ['tasmin','tasmax','pr']
ls_periods = ['pres','fut']
ls_scale_methods = ['Dtrans','Dscaling']


h5files_model = get_model_h5files(h5folder, model)

#for scale_meth in ls_scale_methods:
#for period in ls_periods:

scale_method = ls_scale_methods[0]
period = ls_periods[1]

metadata = {'model_ipcc':'','scenario_ipcc':'','run_ipcc':'','mod_code_ouranos':'','scale_meth': scale_method, 'period': period, 'climvar': '', 'date': '', 'is_obs': False, 'is_pred': True}

logging.info('METADATA: %s',model)
logging.info('\t Scaling method: %s',metadata['scale_meth'])
logging.info('\t Time period: %s',metadata['period'])

# Adjust struct by period
if metadata['period'] == 'fut':
	ndatasets = 2 
if metadata['period'] == 'pres':
	ndatasets = 1

#for ndataset in range(0,ndatasets):
#Get dates_reference
ndataset = 0
ref_hfile =  import_h5(h5folder,h5files_model['name'][0])
dates = get_dates_pred(ref_hfile , metadata,ndataset)

# Loop over dates
#for dat in range(0,len(dates)):
dat = 0
metadata['date'] = dates[dat]
logging.info('\t Date: %s',metadata['date'])

dict_out_climvars = {'pr': pd.DataFrame() ,'tasmin': pd.DataFrame() ,'tasmax': pd.DataFrame()}

#Loop over climvar
for climvar in ls_climvars:
	logging.info('\t Climatic variable: %s',climvar)
	metadata['climvar'] = climvar

	# Loop over files
	for id_file in range(0,len(h5files_model)):
			
		hfile = import_h5(h5folder,h5files_model['name'][id_file])

		# fill metadata
		get_model_mdata(hfile,metadata)

		# Request data (clim, coords)
		clim_var = get_clim_var_pred( hfile , metadata, dat, ndataset)
		coord_cells = get_cells_centroid_pred(hfile)

		df_out = pd.DataFrame(coord_cells)
		df_out[climvar] = clim_var

		dict_out_climvars[climvar] = dict_out_climvars[climvar].append(df_out)

get_write_del_doublons(dict_out_climvars)

# merge and reshape all climatic variable dataframe
df_merge_all_climvars = pd.merge(dict_out_climvars['pr'],dict_out_climvars['tasmin'],on=['lat','lon'])
df_merge_all_climvars = pd.merge(df_merge_all_climvars,dict_out_climvars['tasmax'],on=['lat','lon'])
#df_merge_all_climvars.to_csv('./out_files/verif_raster'+metadata['date']+'.csv',index=False)

arr = df_merge_all_climvars.pivot(index='lat', columns='lon', values='pr')
arr = arr.fillna(-99999.99)

xres = arr.columns[1] - arr.columns[0]
yres = arr.index[1] - arr.index[0]

ysize = len(arr.index[:])
xsize = len(arr.columns[:])

uly = arr.index[-1] - (yres / 2.)
ulx = arr.columns[0] - (xres / 2.)

driver = gdal.GetDriverByName('GTiff')
ds = driver.Create("./out_files/test_rs.tif", xsize, ysize, 1, gdal.GDT_Float32)

# this assumes the projection is Geographic lat/lon WGS 84
srs = osr.SpatialReference()
srs.ImportFromEPSG(4326)
ds.SetProjection(srs.ExportToWkt())

gt = [ulx, xres, 0, uly, 0, yres ]
ds.SetGeoTransform(gt)

outband = ds.GetRasterBand(1)
outband.WriteArray(arr.as_matrix())
outband.SetNoDataValue(-99999.99)