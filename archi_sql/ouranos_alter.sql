-- Modifs / Alter table

-- ALTER TABLE clim_rs.fut_clim_vars ADD COLUMN var varchar(10);
-- ALTER TABLE  ADD COLUMN scenario varchar(10);
-- ALTER TABLE clim_rs.fut_clim_vars RENAME COLUMN year TO yr;

UPDATE clim_rs.fut_clim_vars
  SET var = t.splt[1], clim_center = t.splt[3], mod=t.splt[4], run=t.splt[5], yr=CAST(splt[9] as integer), scenario=splt[6]
FROM (
SELECT DISTINCT regexp_split_to_array(filename,'[+-.]') as splt, filename FROM clim_rs.fut_clim_biovars
) t
WHERE fut_clim_vars.filename=t.filename;
