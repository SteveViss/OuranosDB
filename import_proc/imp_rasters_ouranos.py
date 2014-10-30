import os
import h5py as h5
import numpy as np
import re
import pandas as pd
import psycopg2

####################################
# FUNCTIONS
####################################


def import_h5( h5folder, name_h5file ):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	try:
		hfile = h5.File(h5folder+name_h5file,'r')
		return hfile

	except:
	  	print 'ERROR: Could not open HDF5 file'



def get_model_h5files (h5folder , model):

	"""  DESC: Surgeret mundanum sublimibus auspiciis quarum surgeret quarum Virtus ut homines.
	"""

	group_h5files = [f for f in os.listdir('./'+ h5folder) if os.path.isfile(os.path.join(h5folder,f)) and group_model in f]

	return group_h5files



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
		print "filters nodes and level are unspecified.."

	return flt


###############################################################################

####################################
# PROGRAM
####################################

# Setup wd
os.chdir("/home/steve/Documents/GitHub/OuranosDB/")

h5folder= 'mat_files/'

group_model = get_model_h5files (h5folder, 'gcm1_cccma_cgcm3_1-sresa1b-run1')
name_h5file = group_h5files[1]

hfile = import_h5(h5folder,name_h5file)


# STRUCT VALIDATION (v2014 wo/ USA)
####################################

"""  UNIT TEST 1: Validate if the structure of the original Hierarchical Data
Format version 5 (or HDF5) produced by MATLAB is consistent with the program
and uncorrupted (md5sum) """

"""  UNIT TEST 2:  A.Validate if the HDF5 file is covering the entire Quebec
region. B.Validate if the observed grid is consistent with the predicted grid """


### MODEL DESC
####################################

"""  UNIT TEST 3: Retrieve informations from the group 'model' and make sure
these informations are already in the metadata table (PostgreSQL) """

model_name_ascii = hfile['out']['model']
desc_model = "".join([chr(item) for item in model_name_ascii])
splt_desc_model = filter(None,re.split('-',desc_model))

### METADATA
####################################

md_ipcc_model = splt_desc_model[0]
md_ipcc_scenario = splt_desc_model[1]
md_run = splt_desc_model[2]

### EXTRACT COORD
####################################

### Get centroid arraw
hfile_cells_centroids = get_cells_centroid_pred(hfile)
hfile_cells_bounds = get_cells_bounds_pred(hfile)

"""  UNIT TEST 4: Validate if cell centroids == median(cell bounds) """

### TRAITEMENT BY SCALING
####################################

### Validation: Group 'Dtrans' has the same structure than 'DScaling'

Dscaling_archi = []
hfile['out']['Dscaling'].visit(Dscaling_archi.append)

Dtrans_archi = []
hfile['out']['Dtrans'].visit(Dtrans_archi.append)

if Dtrans_archi == Dscaling_archi is False:
	  print('Prob with file %s: Dtrans and Dscaling (HDF architecture) are differing')
	  sys.exit(1)

common_archi = Dscaling_archi

####################################
####################################
# PROCESS 
####################################
####################################

## Process on pres 
hdf_paths = flt_hdf_paths(common_archi,['fut','tasmin'],2)
