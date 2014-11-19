#! /usr/bin/env python
#
#
# This is a simple utility used to dump Ouranos RCM outputs 
# into raster objects. Each raster are store in a postgreSQL 
# database with postGIS.
# For more details about this tool, see Specification page:
# https://github.com/SteveViss/OuranosDB
#
# The script requires Python 2.7+
################################################################################
# The MIT License (MIT)
# Copyright (c) 2014 Steve Vissault

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
################################################################################

import h5py as h5
import numpy as np
import pandas as pd
import psycopg2
import logging
import os,re,time,sys,getopt

####################################
# PROGRAM
####################################
def main(arguments):

	# OPEN LOG
	logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s',filename=cur_datetime('fulldatetime')+'_import_h5.log',level=logging.DEBUG, datefmt='%m/%d/%Y %I:%M:%S %p')

	# Setup wd
	os.chdir(os.getcwd())

	# IMPORT PROGRAM ARGUMENTS
	h5folder = model = None
	opts, args = getopt.getopt(arguments,"hf:m:",["h5folder=","model="])

	for opt, arg in opts:
		if opt == '-h':
		   print 'test.py -f <h5folder> -m <model>'
		   sys.exit()
		elif opt in ("-f", "--h5folder"):
		   h5folder = arg+"/"
		elif opt in ("-m", "--model"):
		   model = arg

	if h5folder is None or model is None:
		raise RuntimeError('Folder (-f) and model (-m) arguments are required')

	# VARIABLES
	ls_climvars = ['tasmin','tasmax','pr']
	ls_periods = ['pres','fut']
	ls_scale_methods = ['Dtrans','Dscaling']

	h5files_model = get_model_h5files(h5folder, model)
	h5files = {}

	# Setup connection with the database
	conn = psycopg2.connect("host=localhost port=5433 dbname=ouranos_db user=postgres")

	#Load hfiles
	for id_file in range(0,len(h5files_model)):
		h5files[h5files_model['region'][id_file]] = import_h5(h5folder,h5files_model['name'][id_file])

	for scale_method in ls_scale_methods:
		for period in ls_periods:

			# Debug 
			#scale_method = ls_scale_methods[0]
			#period = ls_periods[1]

			# Write metadata of the model group in dict 
			metadata = {'model_ipcc':'','scenario_ipcc':'','run_ipcc':'','mod_code_ouranos':'','scale_meth': scale_method, 'period': period, 'climvar': '', 'date': '', 'is_obs': False, 'is_pred': True}

			logging.info('METADATA: %s',model)
			logging.info('\t Scaling method: %s',metadata['scale_meth'])
			logging.info('\t Time period: %s',metadata['period'])

			# Adjust struct by period
			if metadata['period'] == 'fut':
				ndatasets = 2 
			if metadata['period'] == 'pres':
				ndatasets = 1


			# Fill metadata in dict
			get_model_mdata(h5files[1],metadata,model)

			# Insert metadata in PostgreSQL DB
			if period == ls_periods[0]:
				for climvar in ls_climvars:
					cur = conn.cursor()
					cur.execute("INSERT INTO ouranos_dev.rs_metadata_tbl (ouranos_version, ref_model_ipcc, ref_scenario_ipcc, run, dscaling_method, is_obs, is_pred, bioclim_var) VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",('v2014', metadata['model_ipcc'],metadata['scenario_ipcc'],int(re.findall('\d+', metadata['run_ipcc'])[0]),metadata['scale_meth'],metadata['is_obs'],metadata['is_pred'],climvar))
					cur.close()
				logging.info('METADATA importation SUCCEED !')


			for ndataset in range(0,ndatasets):

				#Get dates_reference
				dates = get_dates_pred(h5files[1],metadata,ndataset)

				# Loop over dates
				for date in range(0,len(dates)):
					metadata['date'] = dates[date]
					logging.info('\t Date: %s',metadata['date'])

					dict_out_climvars = {'pr': pd.DataFrame() ,'tasmin': pd.DataFrame() ,'tasmax': pd.DataFrame()}

					# Loop over files
					for hfile in h5files:

						#Loop over climvar
						for climvar in ls_climvars:
							metadata['climvar'] = climvar

							# Request data (clim, coords)
							clim_var = get_clim_var_pred(h5files[hfile], metadata, climvar, date, ndataset)
							coord_cells = get_cells_centroid_pred(h5files[hfile])

							df_out = pd.DataFrame(coord_cells)
							df_out[climvar] = clim_var

							dict_out_climvars[climvar] = dict_out_climvars[climvar].append(df_out)

					dict_out_climvars = get_write_del_doublons(dict_out_climvars)
					df_merge_all_climvars = merge_dict_in_df(dict_out_climvars)
					write_rs(df_merge_all_climvars,metadata,ls_climvars)

					ls_asc_files = [f for f in os.listdir('./out_files/') if '.asc' in f]
					dict_hex = {'pr':'','tasmin':'','tasmax':''}

					# generate INSERT with raster2pgsql 
					for asc_file in ls_asc_files:
						command = 'python ./raster2pgsql.py -a -s 4326 -r ./out_files/'+asc_file+' -t modclim.rs_content_tbl -f rs_content > ./out_files/' + asc_file.replace(".asc",".sql")
						os.system(command)

						# Get hex code
						insert_line=open('./out_files/'+asc_file.replace(".asc",".sql")).readlines()[1]
						hex_code = re.findall(r'\'(.*?)\'', insert_line)

						#Store hex code
						climvar_file = re.split('_',asc_file)[0]
						dict_hex[climvar_file] = hex_code[0]

					# Clean out_files folder
					os.system('rm ./out_files/*.sql ./out_files/*.asc')

					# Retrieve metadata id from the database
					if date == 0:
						cur = conn.cursor()
						cur.execute("SELECT bioclim_var, md_id FROM ouranos_dev.rs_metadata_tbl WHERE ouranos_version = %s AND ref_model_ipcc = %s AND ref_scenario_ipcc = %s AND run = %s AND dscaling_method = %s AND is_obs = %s AND is_pred = %s;",('v2014', metadata['model_ipcc'],metadata['scenario_ipcc'],int(re.findall('\d+', metadata['run_ipcc'])[0]),metadata['scale_meth'],metadata['is_obs'],metadata['is_pred']))
						md_id_vars = cur.fetchall()
						dict_md_id_vars = dict(md_id_vars)

					# Insert rasters in postgreSQL
					for climvar in ls_climvars:
						cur = conn.cursor()
						cur.execute("INSERT INTO ouranos_dev.rs_content_tbl (md_id_rs_metadata_tbl, rs_date, raster ) VALUES (%s,%s,%s :: raster)",(str(dict_md_id_vars[climvar]),metadata['date'],dict_hex[climvar]))
						cur.close()
					
					conn.commit()	

	conn.close()


####################################
# FUNCTIONS
####################################

def cur_datetime(opt):

	"""	DESCRIPTION: Get the datetime (formatted) from your machine.
		ARGUMENTS: 
		1. fulldatetime: format datime as 2014-11-12T11:20:30
		2. date: format date as 2014-11-12
	"""

	current_time = time.localtime()
	if opt == 'fulldatetime': 
		return time.strftime('%Y-%m-%dT%H:%M:%S', current_time)
	elif opt == 'date':
		return time.strftime('%Y-%m-%d', current_time)
	else :
		logging.error('cur_datetime(): opt argument is unspecified...')
		sys.exit(1)


def import_h5( h5folder, name_h5file ):

	""" DESCRIPTION: Load HDF5 file in memory using the module h5py
		ARGUMENTS: 
		1. h5folder - name of the folder containing HDF5 files
		2. name_h5file - name of the HDF5 file
	"""

	try:
		hfile = h5.File(h5folder+name_h5file,'r')
		return hfile

	except:
		logging.error('import_h5(): Could not open HDF5 file')
		sys.exit(1)


def get_model_h5files (h5folder , group_model):

	""" DESCRIPTION: Get all HDF5 files in the HDF5 folder containing the name of the model
		ARGUMENTS: 
		 1. h5folder - name of the folder containing HDF5 files
		 2. group_model - name of the model (e.g. 'gcm1_cccma_cgcm3_1-sresa1b-run1')
	"""

	group_h5files = [f for f in os.listdir('./'+ h5folder) if os.path.isfile(os.path.join(h5folder,f)) and group_model in f]

	df_group_h5file = pd.DataFrame({'name': group_h5files,'region': [int(elem[:2]) for elem in group_h5files ]})
	df_group_h5file = df_group_h5file.sort(['region'])
	df_group_h5file.index = range(0,len(df_group_h5file))

	return df_group_h5file



def get_cells_bounds_pred( hfile, out = False):


	""" DESCRIPTION: Extract from a h5file (class h5py), all cells boundaries (min and max latitude and longitude)
		ARGUMENTS: 
		 1. h5file - h5file open with the h5py module
		 2. out - if out == True, write cells_bounds dataframe to a CSV file in out_files folder 
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

	""" DESCRIPTION: Extract from a h5file (class h5py), all cells centroid (median latitude and longitude)
		ARGUMENTS: 
		 1. h5file - h5file open with the h5py module
		 2. out - if out == True, write cells_centroid dataframe to a CSV file in out_files folder 
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

	""" DESCRIPTION: Get all dates contained in the h5file (class h5py) for a specific period (future or present) and down-scaling method
		ARGUMENTS: 
		 1. h5file - h5file open with the h5py module
		 2. metadata - Dictionnary object storing metadata informations on the model
		 3. ndataset - integer corresponding to the number of datasets contained in 'dates' (fut = 2 and pres = 1)
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

def get_clim_var_pred( hfile , metadata, climvar, date, ndataset):


	""" DESCRIPTION: Extract all values of a bioclimatic variable given a specific date and period
		ARGUMENTS: 
		 1. h5file - h5file open with the h5py module
		 2. metadata - Dictionnary object storing metadata informations on the model
		 3. climvar - string corresponding to the name of the bioclimatic variable targeted (see ls_climvars)
		 4. date - integer attributing a specific date in the list object "dates"
		 5. ndataset - integer corresponding to the number of datasets contained in 'dates' (fut = 2 and pres = 1)
	"""

	hdf_path_data = "/".join(['out',metadata['scale_meth'],metadata['period'],metadata['climvar'],'data'])

	ls_climvar = []
	dataset_clim_date = hfile[hfile[hdf_path_data][ndataset,0]][...,date].astype(float)
		
	for n in range(0,len(dataset_clim_date)):
		ls_climvar.append(dataset_clim_date[n])

	return ls_climvar

def get_write_del_doublons(dict_out_climvars,delete=True):

	""" DESCRIPTION: Check if the grid have doublons (cells appear twice). This functions keep a track of any of those doublons writing a file (with _doublons_ tag) in the folder out_files and delete them. 
		ARGUMENTS: 
		 1. dict_out_climvars - Dictionnary containing dataframe with the full grid and the value of the bioclimatic variable. Dict keys are corresponding to the name of the variable in ls_climvars
		 2. delete - if delete == True (by default), each doublons are deleted in the returned object of this functions
	"""

	dict_dup_climvars = {'pr':pd.DataFrame(),'tasmin':pd.DataFrame(),'tasmax':pd.DataFrame()}

	for item in dict_out_climvars:
		dict_dup_climvars[item] = dict_out_climvars[item][dict_out_climvars[item].duplicated(['lat','lon'])]

		if not dict_dup_climvars[item].empty:
			dict_dup_climvars[item].to_csv("out_files/"+model+"_doublons_"+item+".csv",index=False)

		if delete == True:
			dict_dup_climvars[item] = dict_out_climvars[item].drop_duplicates(['lat','lon'])

	return dict_out_climvars

def get_model_mdata(hfile,metadata,model):

	""" DESCRIPTION: Write metadata of the model in a the dictionnary object.
		ARGUMENTS: 
		 1. h5file - h5file open with the h5py module
		 2. metadata - Dictionnary object storing metadata informations of the model
		 3. model - name of the model (e.g. 'gcm1_cccma_cgcm3_1-sresa1b-run1')
	"""

	desc_model =  filter(None,re.split('-',"".join([chr(item) for item in hfile['out']['model']])))

	metadata['model_ipcc'] = desc_model[0]
	metadata['scenario_ipcc']  = desc_model[1]
	metadata['run_ipcc'] = desc_model[2]
	metadata['mod_code_ouranos'] = re.split('-|_',model)[0]

	return metadata

def merge_dict_in_df(dict_out_climvars,out=False):

	""" DESCRIPTION: Merge all dataframes contained in dict_out_climvars into one final dataframe (lon, lat, pr, tasmin, tasmax)
		ARGUMENTS: 
		 1. dict_out_climvars - Dictionnary containing dataframe with the full grid and the value of the bioclimatic variable. Dict keys are corresponding to the name of the variable in ls_climvars
		 2. out - if out == True, the dataframe will be write in the out_files folder.
	"""

	# merge and reshape all climatic variable in panda dataframe
	df_merge_all_climvars = pd.merge(dict_out_climvars['pr'],dict_out_climvars['tasmin'],on=['lat','lon'])
	df_merge_all_climvars = pd.merge(df_merge_all_climvars,dict_out_climvars['tasmax'],on=['lat','lon'])
	
	if out == True:
		df_merge_all_climvars.to_csv('./out_files/'+metadata['model']+'_verif_raster'+metadata['date']+'.csv',index=False)

	return df_merge_all_climvars

def write_rs(df_merge_all_climvars,metadata,ls_climvars):
	""" DESCRIPTION: Write dataframe named df_merge_all_climvars containing all bioclimatic variables and centroid of all cells to an ASCII raster (.asc).
	ARGUMENTS: 
	 1. dict_out_climvars - Dictionnary containing dataframe with the full grid and the value of the bioclimatic variable. Dict keys are corresponding to the name of the variable in ls_climvars
	 2. metadata - Dictionnary object storing metadata informations of the model
	 3. ls_climvars - List of the bioclimatic variables
	"""

	for climvar in ls_climvars:
		arr = df_merge_all_climvars.pivot(index='lat', columns='lon', values=climvar)
		arr = arr.sort_index(axis=0,ascending=False)

		ysize = len(arr.index[:])
		xsize = len(arr.columns[:])
		lly = arr.index[-1]
		llx = arr.columns[0]
		res = arr.columns[1] - arr.columns[0]
		no_dat_val = 9.999999999900000694e+04
		arr = arr.fillna(no_dat_val)

		with file("./out_files/"+"_".join([climvar,metadata['model_ipcc'],metadata['date']+'.asc']),'w') as asc_out:
			asc_out.write('NCOLS '+str(xsize)+'\n')
			asc_out.write('NROWS '+str(ysize)+'\n')
			asc_out.write('XLLCENTER '+str(llx)+'\n')
			asc_out.write('YLLCENTER '+str(lly)+'\n')
			asc_out.write('CELLSIZE '+str(res)+'\n')
			asc_out.write('NODATA_VALUE '+str(no_dat_val)+'\n')
			np.savetxt(asc_out, arr.as_matrix(), delimiter=' ')



if __name__ == "__main__":
   main(sys.argv[1:])
