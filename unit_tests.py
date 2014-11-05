
# Setup tests for all files

# """ UNDONE  TEST 1: Validate if the structure of the original Hierarchical Data
# Format version 5 (or HDF5) produced by MATLAB is consistent with the program
# and uncorrupted (md5sum) """

# """ UNDONE TEST 2:  A.Validate if the HDF5 file is covering the entire Quebec
# region. B.Validate if the observed grid is consistent with the predicted grid """

# STRUCT VALIDATION (v2014 wo/ USA)
####################################

### Validation: Group 'Dtrans' has the same structure than 'DScaling'

# Dscaling_archi = []
# hfile['out']['Dscaling'].visit(Dscaling_archi.append)
# 
# Dtrans_archi = []
# hfile['out']['Dtrans'].visit(Dtrans_archi.append)
# 
# """  TEST 3 Validat if Dtrans and Dscaling (HDF architecture) are differing"""
# if Dtrans_archi != Dscaling_archi :
# 		logging.error('%s - Dtrans and Dscaling (HDF architecture) are differing', name_h5file)
# 		sys.exit(1)
# 		# replace by next i

#"""  TEST 6: Validate if cell centroids == median(cell bounds) """

# """  TEST 5: Validate if name of the file is consistent with informations in hfile['out']['model'] """

# if splt_desc_model != splt_name_model:
# 	logging.error('%s - Mismatch between filname and metadata contained (["out"]["model"]) \n \t splt_name_model : %s  != splt_desc_model: %s', name_h5file, splt_name_model,splt_desc_model)
# 	sys.exit(1)


# """  TEST 7: Have a look on flt_hdf_paths (test if 1 element is returned) """
# if len(hdf_path_dates) != len(hdf_path_data) != 1:
# 	logging.error('%s - lenght of hdf_path_dates or hdf_path_data should be equal to 1: %s', name_h5file, hdf_path_dates)
# 	sys.exit(1)

# """  TEST 8: test number of datasets (pres or fut) """
# if metadata['period'] == 'pres' and hfile[hdf_path_dates[0]].size != 1: 
# 	logging.error('%s - pres path should have 1 dataset (one period of time)', name_h5file)
# 	sys.exit(1)
# elif metadata['period'] == 'fut' and hfile[hdf_path_dates[0]].size != 2: 
# 	logging.error('%s - fut path should have 2 datasets (two periods of time)', name_h5file)
# 	sys.exit(1)


# """  TEST 9: test if nDates are equal to number of row in datasets """
# if len(dataset_fulldate) != hfile[hfile[hdf_path_data[0]][ndataset,0]][1,...].size:
# 	logging.error('%s - number of observation from climatic variable dataset is different to the number of date', name_h5file)
# 	sys.exit(1)

# """  TEST 10: test if nCells are equal to number of columns in datasets """
# if len(cells_bounds) != len(var_clim_date)-1:
# 	logging.error('%s - number of cells from grid informations is different to the number of cells in climatic variable dataset', name_h5file)
# 	sys.exit(1)
