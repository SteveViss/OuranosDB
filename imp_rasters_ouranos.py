import os
import h5py as h5
import numpy as np
import re
import pandas as pd
import psycopg2 as pg
import logging
import time
import sys


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

	return df_group_h5file



def get_cells_bounds_pred( hfile, out = False):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	bound_grids = hfile['out']['grid']['BoundingBox']
	ls_bound = []

	for i in range(0,bound_grids.size-1):
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

	for i in range(0,nCells-1):
		lon_centroids = hfile[hfile['out']['grid']['X1'][0,i]][0,0]
		lat_centroids = hfile[hfile['out']['grid']['Y1'][0,i]][0,0]
		dict_row = {'lon': lon_centroids,'lat': lat_centroids}
		ls_centroid.append(dict_row)


	if out == True:
		df_centroid = pd.DataFrame(ls_centroid)
		df_centroid.to_csv("out_files/"+h5file.replace(".mat","_centroid.csv"),index=False)

	return ls_centroid

def get_dates_pred( hfile , hdf_path_dates, ndataset):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""
	dataset_dates_yr = hfile[hfile[hdf_path_dates[0]][ndataset,0]][0,...].astype(int)
	dataset_dates_month = hfile[hfile[hdf_path_dates[0]][ndataset,0]][1,...].astype(int)
	dataset_dates_day = hfile[hfile[hdf_path_dates[0]][ndataset,0]][2,...].astype(int)

	dataset_fulldate = []

	for date in range(0,len(dataset_dates_day)):
		year = dataset_dates_yr[date].astype(str)
		month = dataset_dates_month[date].astype(str)
		day = dataset_dates_day[date].astype(str)

		if len(month) == 1:
			month = '0' + month
		if len(day) == 1:
			day = '0' + day

		date = "-".join([year,month,day])
		dataset_fulldate.append(date)

	return dataset_fulldate

def flt_hdf_paths(ls,nodes = None,level = None):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	if nodes and level :
		if type(nodes) == list:

			flt = [elem for elem in ls if elem.count('/') == level]
			for node in nodes:
				flt = [elem for elem in flt if node in elem]

		else: 
			flt = [elem for elem in ls if elem.count('/') == level and nodes in elem]

	elif nodes and not level :
		if type(nodes) == list:
			for node in nodes:
				flt = [elem for elem in flt if node in elem]
		else:
			flt = [elem for elem in ls if nodes in elem]

	elif not nodes and level :
		flt = [elem for elem in ls if elem.count('/') == level]

	else :
		logging.error('flt_hdf_paths(): filters nodes and level are both unspecified..')
		sys.exit(1)

	return flt


###############################################################################

logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',filename=cur_datetime('fulldatetime')+'_import_h5.log',level=logging.DEBUG, datefmt='%m/%d/%Y %I:%M:%S %p')

####################################
# PROGRAM
####################################

# Setup wd
os.chdir("/home/steve/Documents/GitHub/OuranosDB/")

h5folder= 'mat_files/'
model = 'gcm1_cccma_cgcm3_1-sresa1b-run1' # for loop

h5files_model = get_model_h5files(h5folder, model)
n_regions = len(h5files_model)

h5file = h5files_model['name'][0] # for loop

hfile = import_h5(h5folder,h5file)

logging.info('Start working on %s',model)

# STRUCT VALIDATION (v2014 wo/ USA)
####################################

""" UNDONE  TEST 1: Validate if the structure of the original Hierarchical Data
Format version 5 (or HDF5) produced by MATLAB is consistent with the program
and uncorrupted (md5sum) """

""" UNDONE TEST 2:  A.Validate if the HDF5 file is covering the entire Quebec
region. B.Validate if the observed grid is consistent with the predicted grid """

### Validation: Group 'Dtrans' has the same structure than 'DScaling'

Dscaling_archi = []
hfile['out']['Dscaling'].visit(Dscaling_archi.append)

Dtrans_archi = []
hfile['out']['Dtrans'].visit(Dtrans_archi.append)

"""  TEST 3 Validat if Dtrans and Dscaling (HDF architecture) are differing"""
if Dtrans_archi != Dscaling_archi :
		logging.error('%s - Dtrans and Dscaling (HDF architecture) are differing', name_h5file)
		sys.exit(1)
		# replace by next i

### MODEL DESC
####################################

"""UNDONE  TEST 4: Retrieve informations from the group 'model' and make sure
these informations are already in the metadata table (PostgreSQL) """

desc_model = "".join([chr(item) for item in hfile['out']['model']])
splt_desc_model = filter(None,re.split('-',desc_model))

md_ipcc_model = splt_desc_model[0]
md_ipcc_scenario = splt_desc_model[1]
md_run = splt_desc_model[2]
md_code_ouranos = re.split('-|_',model)[0]

splt_name_model = re.split('-',model)
splt_desc_model[0] = md_code_ouranos + '_' + splt_desc_model[0]

"""  TEST 5: Validate if name of the file is consistent with informations in hfile['out']['model'] """

if splt_desc_model != splt_name_model:
	logging.error('%s - Mismatch between filname and metadata contained (["out"]["model"]) \n \t splt_name_model : %s  != splt_desc_model: %s', name_h5file, splt_name_model,splt_desc_model)
	sys.exit(1)
	# replace by next i


### EXTRACT COORD
####################################

### Get centroid arraw
cells_centroids = get_cells_centroid_pred(hfile)
cells_bounds = get_cells_bounds_pred(hfile)

"""  TEST 6: Validate if cell centroids == median(cell bounds) """

### TRAITEMENT
####################################

common_archi = []
hfile.visit(common_archi.append)

####################################
####################################
# PROCESS 
####################################
####################################

ls_climvars = ['tasmin','tasmax','pr/']
ls_periods = ['pres','fut']
ls_scale_methods = ['Dtrans','Dscaling']

#for scale_meth in ls_scale_methods:
	#for period in ls_periods:
		#for climvar in ls_climvars:

#### WARNINGS !!!! Need to be replaced when the loop will be setup
metadata = {'scale_meth': ls_scale_methods[0], 'period': ls_periods[1], 'climvar': ls_climvars[0], 'date': ''}
			
# Set filter criteria
flt_crit_dates = [metadata['scale_meth'],metadata['period'],metadata['climvar'],'dates']
flt_crit_data = [metadata['scale_meth'],metadata['period'],metadata['climvar'],'data']

# Get paths 
hdf_path_dates = flt_hdf_paths(common_archi,flt_crit_dates,4)
hdf_path_data = flt_hdf_paths(common_archi,flt_crit_data,4)


"""  TEST 7: Have a look on flt_hdf_paths (test if 1 element is returned) """
if len(hdf_path_dates) != len(hdf_path_data) != 1:
	logging.error('%s - lenght of hdf_path_dates or hdf_path_data should be equal to 1: %s', name_h5file, hdf_path_dates)
	sys.exit(1)


"""  TEST 8: test number of datasets (pres or fut) """
if metadata['period'] == 'pres' and hfile[hdf_path_dates[0]].size != 1: 
	logging.error('%s - pres path should have 1 dataset (one period of time)', name_h5file)
	sys.exit(1)
elif metadata['period'] == 'fut' and hfile[hdf_path_dates[0]].size != 2: 
	logging.error('%s - fut path should have 2 datasets (two periods of time)', name_h5file)
	sys.exit(1)


# Loop on period 
##################

#for ndataset in range(0,datasets_dates.size-1):
ndataset = 0

# Get dates dataset
dataset_fulldate = get_dates_pred(hfile , hdf_path_dates, ndataset)

"""  TEST 9: test if nDates are equal to number of row in datasets """
if len(dataset_fulldate) != hfile[hfile[hdf_path_data[0]][ndataset,0]][1,...].size:
	logging.error('%s - number of observation from climatic variable dataset is different to the number of date', name_h5file)
	sys.exit(1)

# Loop on date
##################

#for date in len(dataset_fulldate):
date = 0

# Add item date in metadata dict
metadata['date'] = dataset_fulldate[date]

# Get var_clim data associated with the date
var_clim_date = hfile[hfile[hdf_path_data[0]][ndataset,0]][...,date].tolist()

"""  TEST 10: test if nCells are equal to number of columns in datasets """
if len(cells_bounds) != len(var_clim_date)-1:
	logging.error('%s - number of cells from grid informations is different to the number of cells in climatic variable dataset', name_h5file)
	sys.exit(1)






