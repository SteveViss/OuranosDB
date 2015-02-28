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

-- object: ouranos_dev | type: SCHEMA --
-- DROP SCHEMA ouranos_dev;
CREATE SCHEMA ouranos_dev;
-- ddl-end --

SET search_path TO pg_catalog,public,ouranos_dev;
-- ddl-end --

-- object: ouranos_dev.mod_rs_ouranos | type: TABLE --
-- DROP TABLE ouranos_dev.mod_rs_ouranos;
CREATE TABLE ouranos_dev.mod_rs_ouranos(
	rs_id serial NOT NULL,
	filename varchar(100) NOT NULL,
	rs_var varchar(10),
	rs_date date,
	raster raster NOT NULL,
	CONSTRAINT rs_pkey PRIMARY KEY (rs_id)

);
-- ddl-end --
-- object: idx_rs_var | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_var;
CREATE INDEX idx_rs_var ON ouranos_dev.mod_rs_ouranos
	USING btree
	(
	  rs_var ASC NULLS LAST
	);
-- ddl-end --

-- object: idx_rs_date | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_date;
CREATE INDEX idx_rs_date ON ouranos_dev.mod_rs_ouranos
	USING btree
	(
	  rs_date ASC NULLS LAST
	);
-- ddl-end --


-- object: spatial_idx | type: INDEX --
-- DROP INDEX ouranos_dev.spatial_idx;
CREATE INDEX spatial_idx ON ouranos_dev.mod_rs_ouranos
	USING gist
	(
	  st_convexhull(raster)
	);
-- ddl-end --

COMMENT ON COLUMN ouranos_dev.mod_rs_ouranos.filename IS 'Name of the HDF file';
COMMENT ON COLUMN ouranos_dev.mod_rs_ouranos.rs_var IS 'Name of the climatic variable';
COMMENT ON COLUMN ouranos_dev.mod_rs_ouranos.rs_date IS 'Date';
-- ddl-end --


