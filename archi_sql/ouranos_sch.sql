-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.7.1
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: quicc_for_dev | type: DATABASE --
-- -- DROP DATABASE quicc_for_dev;
-- CREATE DATABASE quicc_for_dev
-- ;
-- -- ddl-end --
--

-- object: clim_rs | type: SCHEMA --
-- DROP SCHEMA clim_rs;
CREATE SCHEMA clim_rs;
-- ddl-end --

SET search_path TO pg_catalog,public,clim_rs;
-- ddl-end --

-- object: clim_rs.mod_rs_ouranos | type: TABLE --
-- DROP TABLE clim_rs.mod_rs_ouranos;
CREATE TABLE clim_rs.fut_clim_vars(
	rs_id serial NOT NULL,
	filename varchar(100) NOT NULL,
	clim_center varchar(20),
	mod varchar(20),
	run varchar(20),
	scenario varchar(20),
	var varchar(10),
	yr integer,
	mth smallint,
	raster raster NOT NULL,
	CONSTRAINT rs_pkey PRIMARY KEY (rs_id)

);
-- ddl-end --
COMMENT ON COLUMN clim_rs.mod_rs_ouranos.filename IS 'Name of the HDF file';
-- ddl-end --


