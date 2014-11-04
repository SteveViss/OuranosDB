-- Database generated with pgModeler (PostgreSQL Database Modeler).
-- pgModeler  version: 0.7.1
-- PostgreSQL version: 9.3
-- Project Site: pgmodeler.com.br
-- Model Author: ---

SET check_function_bodies = false;
-- ddl-end --


-- Database creation must be done outside an multicommand file.
-- These commands were put in this file only for convenience.
-- -- object: modclim_db | type: DATABASE --
-- -- DROP DATABASE modclim_db;
-- CREATE DATABASE modclim_db
-- ;
-- -- ddl-end --
-- 

-- object: modclim | type: SCHEMA --
-- DROP SCHEMA modclim;
CREATE SCHEMA modclim;
-- ddl-end --

SET search_path TO pg_catalog,public,modclim;
-- ddl-end --

-- object: modclim.rs_metadata_tbl | type: TABLE --
-- DROP TABLE modclim.rs_metadata_tbl;
CREATE TABLE modclim.rs_metadata_tbl(
	md_id serial NOT NULL,
	ouranos_version varchar(20),
	ref_model_ipcc varchar(15) NOT NULL,
	ref_scenario_ipcc varchar(15) NOT NULL,
	run smallint NOT NULL,
	dscaling_method varchar(10) NOT NULL,
	is_obs boolean NOT NULL,
	is_pred boolean NOT NULL,
	bioclim_var varchar(20) NOT NULL,
	CONSTRAINT rs_metadata_tbl_pkey PRIMARY KEY (md_id)

);
-- ddl-end --
-- object: idx_rs_metadata_pkey | type: INDEX --
-- DROP INDEX modclim.idx_rs_metadata_pkey;
CREATE UNIQUE INDEX idx_rs_metadata_pkey ON modclim.rs_metadata_tbl
	USING btree
	(
	  md_id ASC NULLS LAST
	);
-- ddl-end --


-- object: modclim.rs_content_tbl | type: TABLE --
-- DROP TABLE modclim.rs_content_tbl;
CREATE TABLE modclim.rs_content_tbl(
	md_id bigint NOT NULL,
	rs_content raster NOT NULL,
	rs_date date NOT NULL,
	md_id_rs_metadata_tbl integer NOT NULL,
	CONSTRAINT rs_content_pkey PRIMARY KEY (md_id)

);
-- ddl-end --
-- object: rs_metadata_tbl_fk | type: CONSTRAINT --
-- ALTER TABLE modclim.rs_content_tbl DROP CONSTRAINT rs_metadata_tbl_fk;
ALTER TABLE modclim.rs_content_tbl ADD CONSTRAINT rs_metadata_tbl_fk FOREIGN KEY (md_id_rs_metadata_tbl)
REFERENCES modclim.rs_metadata_tbl (md_id) MATCH FULL
ON DELETE CASCADE ON UPDATE CASCADE;
-- ddl-end --



