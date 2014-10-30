import os
import h5py as h5
import numpy as np
import re
import pandas as pd
import psycopg2
import logging
import time


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


def import_h5( h5folder, name_h5file ):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	try:
		hfile = h5.File(h5folder+name_h5file,'r')
		return hfile

	except:
		logging.error('import_h5(): Could not open HDF5 file')


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

	df_bound = pd.DataFrame(ls_bound)

	if out == True:
		df_bound.to_csv("out_files/"+h5file.replace(".mat","_bound.csv"),index=False)

	return df_bound



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

	df_centroid = pd.DataFrame(ls_centroid)

	if out == True:
		df_centroid.to_csv("out_files/"+h5file.replace(".mat","_centroid.csv"),index=False)

	return df_centroid



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

group_model = get_model_h5files(h5folder, model)
n_regions = len(group_model)

name_h5file = group_model['name'][0] # for loop

hfile = import_h5(h5folder,name_h5file)

logging.info('Start working on %s',model)

# STRUCT VALIDATION (v2014 wo/ USA)
####################################

"""  TEST 1: Validate if the structure of the original Hierarchical Data
Format version 5 (or HDF5) produced by MATLAB is consistent with the program
and uncorrupted (md5sum) """

"""  TEST 2:  A.Validate if the HDF5 file is covering the entire Quebec
region. B.Validate if the observed grid is consistent with the predicted grid """

### Validation: Group 'Dtrans' has the same structure than 'DScaling'

Dscaling_archi = []
hfile['out']['Dscaling'].visit(Dscaling_archi.append)

Dtrans_archi = []
hfile['out']['Dtrans'].visit(Dtrans_archi.append)

"""  TEST 3 Validat if Dtrans and Dscaling (HDF architecture) are differing"""
if Dtrans_archi != Dscaling_archi :
		logging.error('%s - Dtrans and Dscaling (HDF architecture) are differing', name_h5file)
		# replace by next i

### MODEL DESC
####################################

"""  TEST 4: Retrieve informations from the group 'model' and make sure
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
	# replace by next i


### EXTRACT COORD
####################################

### Get centroid arraw
hfile_cells_centroids = get_cells_centroid_pred(hfile)
hfile_cells_bounds = get_cells_bounds_pred(hfile)

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

scale_meth = ls_scale_methods[0]
period = ls_periods[0]
climvar = ls_climvars[0]
			
# Set filter criteria
flt_crit_dates = [scale_meth,period,climvar,'dates']
flt_crit_data = [scale_meth,period,climvar,'data']


# Get paths
hdf_path_dates = flt_hdf_paths(common_archi,flt_crit_dates,4)
hdf_path_data = flt_hdf_paths(common_archi,flt_crit_data,4)

if len(hdf_path_dates) != 1 :
	logging.error('%s - lenght of hdf_path_dates should be equal to 1: %s', name_h5file, hdf_path_dates)

if len(hdf_path_data) != 1 :
	logging.error('%s - lenght of hdf_path_data should be equal to 1: %s', name_h5file, hdf_path_data)

# Get dates

ref_dates = hfile[hdf_path_dates[0]]

# Get data

ref_data = hfile[hdf_path_data[0]]

# Writing last metadata info
md_scale_method = scale_meth
md_climvar = climvar