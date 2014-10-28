import os
import h5py as h5
import numpy as np
import re
import pandas as pd


####################################
# FUNCTIONS
####################################


def import_h5( h5folder, name_h5file ):

	hfile = h5.File(h5folder+name_h5file,'r') 

	if hfile is None:
	  print 'Could not open HDF5 file'
	  sys.exit(1)

	return hfile

def extract_bounds_to_csv( hfile ):

	## Extract centroid of observed cells

	# if "observed" in name_h5file:
	# Need to be done !

	## Extract boundaries of predicted cells

	bound_grids = hfile['out']['grid']['BoundingBox']
	ls_bound = []

	for i in range(0,bound_grids.size-1):
		new_row = hfile[mat['out']['grid']['BoundingBox'][0,i]]
		dict_row = {'lon_min': new_row[0,0],'lon_max': new_row[0,1],'lat_min': new_row[1,0],'lat_max': new_row[1,1]}
		ls_bound.append(dict_row)

	df_bound = pd.DataFrame(ls_bound)
	df_bound.to_csv("bound_files/"+h5file.replace(".mat","_bound.csv"),index=False)

def get_grid_index ():


####################################
# PROG
####################################

# Setup wd
os.chdir("/home/steve/Documents/GitHub/OuranosDB/")

h5folder = 'mat_files/'
name_h5file = '01_gcm1_cccma_cgcm3_1-sresa1b-run1.mat'

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
splt_desc_model = filter(None,re.split('-|_',desc_model))

### Create raster
####################################



