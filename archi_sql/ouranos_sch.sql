-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.7.1
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: Steve Vissault---

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

-- object: ouranos_dev.rs_content_tbl | type: TABLE --
-- DROP TABLE ouranos_dev.rs_content_tbl;
CREATE TABLE ouranos_dev.rs_content_tbl(
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
CREATE INDEX idx_rs_var ON ouranos_dev.rs_content_tbl
	USING btree
	(
	  rs_var ASC NULLS LAST
	);
-- ddl-end --

-- object: idx_rs_date | type: INDEX --
-- DROP INDEX ouranos_dev.idx_rs_date;
CREATE INDEX idx_rs_date ON ouranos_dev.rs_content_tbl
	USING btree
	(
	  rs_date ASC NULLS LAST
	);
-- ddl-end --


COMMENT ON COLUMN ouranos_dev.rs_content_tbl.filename IS 'Name of the HDF file';
COMMENT ON COLUMN ouranos_dev.rs_content_tbl.rs_var IS 'Name of the climatic variable';
COMMENT ON COLUMN ouranos_dev.rs_content_tbl.rs_date IS 'Raster date';
-- ddl-end --


