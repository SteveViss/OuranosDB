import os
import scipy.io as sio
import h5py as h5
import numpy as np
import re
import pandas as pd

# Setup wd
os.chdir("/home/steve/Documents/Maitrise/StageMFFP/BD_CLIM/")

# import .mat file
h5folder = 'MAT_FILES/'
h5file = '16_gcm16_cccma_cgcm3_1_t63-sresa1b-run1.mat'
mat = h5.File(h5folder+h5file,'r') 


# .mat validation (based on file struct)

""" 
UNIT TEST 1: Validate if the structure of the original Hierarchical Data Format version 5 (or HDF5) produced by MATLAB is consistent with the program and uncorrupted (md5sum)
"""

## Explo grid cover

""" 
UNIT TEST 2: Validate if the HDF5 file is covering the entire Quebec region”
"""

bound_grids = mat['out']['grid']['BoundingBox']
ls_bound = []

for i in range(0,bound_grids.size-1):
	new_row = mat[mat['out']['grid']['BoundingBox'][0,i]]
	dict_row = {'lon_min': new_row[0,0],'lon_max': new_row[0,1],'lat_min': new_row[1,0],'lat_max': new_row[1,1]}
	ls_bound.append(dict_row)

df_bound = pd.DataFrame(ls_bound)
df_bound.to_csv("BOUND_FILES/"+h5file.replace(".mat","_bound.csv"),index=False)

### Model desc

""" 
UNIT TEST 3: Retrieve informations from the group 'model' and make sure these informations are already in the metadata table (PostgreSQL)
"""

model_name_ascii = mat['out']['model']
desc_model = "".join([chr(item) for item in model_name_ascii])
splt_desc_model = filter(None,re.split('-|_',desc_model))




