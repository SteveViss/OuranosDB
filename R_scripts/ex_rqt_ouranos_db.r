### Exemple de requête et visualisation à partir de la base de données Ouranos 
### (version de développement)
### By Steve Vissault
### 26 novembre 2014

## Remarques: Les temps de réponses des requêtes (vers la BD) sont excellent. 
## Les requêtes sont enchassées dans la fonction system.time() (Benchmark, voir par exemple l.56)
## Si tu veux savoir comment l'interpréter, tape: '?system.time' dans la console

#############################################################################
######### Importation des librairies et configuration de l'espace de travail
#############################################################################

require("ggplot2")
require("RPostgreSQL")
require("RColorBrewer")

#install.package("RPostgreSQL")
#install.package("ggplot2")
#install.package("RColorBrewer")

# Définit l'espace de travail pour la sortie des figures
setwd("~/Desktop")

##############################################################
######### Connection de la base de données à R
##############################################################

dbname <- "ouranos_db" # Change pour le nom de BD ou tu as fait le pg_restore (soit la restauration de la BD qui était sur le FTP)
dbuser <- "postgres" # Change pour ton utilisateur
dbpass <- "maple" # Change pour ton mot de passe
dbhost <- "localhost" # Par défault localhost
dbport <- 5433 # Par défault 5432 (pour moi 5433)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv, host=dbhost, port=dbport, dbname=dbname,
                 user=dbuser, password=dbpass) 

##############################################################
######### Aggregation temporelle (par mois pour l'année 1971) 
############### Requêtes
##############################################################

# Obtenir les 12 raster mensuelles pour l'année 1971 pour l'ensemble du québec et les 3 variable climatiques (tasmin, tasmax, pp)

query_monthly_rs_qc <- "
DROP MATERIALIZED VIEW IF EXISTS ouranos_dev.MonthlyUnion;
CREATE MATERIALIZED VIEW ouranos_dev.MonthlyUnion AS (SELECT rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date) as Month_date,extract(year from rs_content_tbl.rs_date) as Year_date,ST_Union(raster, 'MEAN') AS union_rasters FROM ouranos_dev.rs_content_tbl
INNER JOIN ouranos_dev.rs_metadata_tbl ON ouranos_dev.rs_content_tbl.md_id_rs_metadata_tbl = ouranos_dev.rs_metadata_tbl.md_id
GROUP BY rs_metadata_tbl.bioclim_var,extract(month from rs_content_tbl.rs_date),extract(year from rs_content_tbl.rs_date));
"

# Cette requête (ci-dessus) supprime la vue matérialisée si elle existe puis la recréée. Cette vue comprend les rasters mensuelles du Québec pour les 3 variables climatiques (voir GROUP BY)

# Envoie de la requête vers la BD pour créer la vue matérialisée
system.time(dbSendQuery(con,query_monthly_rs_qc))

# Requête pour obtenir tous les rasters contenus dans la vue matérialisée
query_view_monthly_rs_qc <- "
	SELECT 
		ST_X(geom) as lon,
		ST_Y(geom) as lat, 
		val, 
		bioclim_var,
		Month_date,
		Year_date 
	FROM (SELECT (
		ST_PixelAsCentroids(union_rasters)).*,
		bioclim_var,
		Month_date,
		Year_date 
		FROM ouranos_dev.MonthlyUnion) AS view_rs;
"
# Récupérer les données à partir de la Base de données
system.time(view_monthly_rs_qc <- dbGetQuery(con, query_view_monthly_rs_qc))

# Filtre les données pour obtenir juste l'année 1971 (l'année 1972 est incomplète)
view_monthly_rs_qc <- subset(view_monthly_rs_qc,year_date == 1971)

# Transforme la date et les variables climatiques comme facteurs
view_monthly_rs_qc$month_date <- as.factor(view_monthly_rs_qc$month_date)
view_monthly_rs_qc$year_date <- as.factor(view_monthly_rs_qc$year_date)
view_monthly_rs_qc$bioclim_var <- as.factor(view_monthly_rs_qc$bioclim_var)

# On renomme les étiquettes des niveaux des facteurs "month_date" et "bioclim_var"
view_monthly_rs_qc$month_date <- factor(view_monthly_rs_qc$month_date,labels=c("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"))

# On subdivise le jeu de données par variable bioclimatique 

pp_1971 <-  subset(view_monthly_rs_qc,bioclim_var == "pr")
tasmin_1971 <-  subset(view_monthly_rs_qc,bioclim_var == "tasmin")
tasmax_1971 <-  subset(view_monthly_rs_qc,bioclim_var == "tasmax")

# on créé des classes de valeurs pour chaque variable bioclimatique
pp_1971$val <- cut(pp_1971$val,11)
tasmin_1971$val <- cut(tasmin_1971$val,11)
tasmax_1971$val <- cut(tasmax_1971$val,11)


##############################################################
######### Aggregation temporelle (par mois pour l'année 1971) 
############### Visualisation des rasters (ggplot2)
##############################################################

# Fait pas attention aux commandes ggplot2
# Elles paraissent cryptiques mais ce package fait un travail rapide, propre et efficace

# Augmente la taille de la police par défault (pour les graphiques)
theme_set(theme_grey(base_size = 12))

# Visualisation avec la variable précipitation
map_pp = ggplot() + 
geom_tile(data=pp_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Précipitation (m) pour l'année 1971")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_pp,file="rasters_pp_1971.pdf",height=6,width=12) # Export le graphique vers le dossier de travail (voir setwd())

# Visualisation avec la variable température min
map_tasmin = ggplot() + 
geom_tile(data=tasmin_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Température minimale (°C) pour l'année 1971")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_tasmin,file="rasters_tasmin_1971.pdf",height=6,width=12)# Export le graphique vers le dossier de travail (voir setwd())

# Visualisation avec la variable température min
map_tasmax = ggplot() + 
geom_tile(data=tasmax_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Température maximale (°C) pour l'année 1971")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_tasmax,file="rasters_tasmax_1971.pdf",height=6,width=12)# Export le graphique vers le dossier de travail (voir setwd())

##############################################################
######### Interception spatiale (avec région administrative)
############### Requêtes
##############################################################

# Cette requête effectue l'interception spatiale entre la 
# région administrative de la Monterigie (polygon) et l'ensemble des rasters
# de l'année 1971 (pour toutes les variables climatiques)

query_clip_mtrg  <- "
SELECT ST_X(geom) as lon,ST_Y(geom) as lat, val, bioclim_var, Month_date,Year_date 
FROM(
	SELECT (ST_PixelAsCentroids(bsl_rasters.rasters_clip)).*,bioclim_var, Month_date,Year_date
	FROM(
		SELECT ST_Clip(MonthlyUnion.union_rasters,env_bsl.env) as rasters_clip, bioclim_var, Month_date,Year_date
		FROM ouranos_dev.MonthlyUnion,
		(SELECT ST_Envelope(ST_Transform(geom,4326)) as env FROM map_qc.regio_s WHERE res_nm_reg = 'Montrgie') as env_bsl
	) as bsl_rasters
) as bsl_pixels
;"

# Envoie la requête et récupère les données la base de données 
system.time(view_clip_rs_mtrg <- dbGetQuery(con, query_clip_mtrg))

## Même transformation que précédemment
# Filtre les données pour obtenir juste l'année 1971 (l'année 1972 est incomplète)
view_clip_rs_mtrg <- subset(view_clip_rs_mtrg,year_date == 1971)

# Transform la date et les variables climatiques comme facteurs
view_clip_rs_mtrg$month_date <- as.factor(view_clip_rs_mtrg$month_date)
view_clip_rs_mtrg$year_date <- as.factor(view_clip_rs_mtrg$year_date)
view_clip_rs_mtrg$bioclim_var <- as.factor(view_clip_rs_mtrg$bioclim_var)

# On renomme les étiquettes des niveaux des facteurs month_date et bioclim_var
view_clip_rs_mtrg$month_date <- factor(view_clip_rs_mtrg$month_date,labels=c("janvier", "février", "mars", "avril", "mai", "juin", "juillet", "août", "septembre", "octobre", "novembre", "décembre"))

#On subdivise le jeu de données par variable bioclimatique et On créer des classes de valeurs pour chaque variable bioclimatique

pp_1971 <-  subset(view_clip_rs_mtrg,bioclim_var == "pr")
tasmin_1971 <-  subset(view_clip_rs_mtrg,bioclim_var == "tasmin")
tasmax_1971 <-  subset(view_clip_rs_mtrg,bioclim_var == "tasmax")

pp_1971$val <- cut(pp_1971$val,11)
tasmin_1971$val <- cut(tasmin_1971$val,11)
tasmax_1971$val <- cut(tasmax_1971$val,11)


##############################################################
######### Interception spatiale (avec région administrative)
############### Visualisation des rasters (ggplot2)
##############################################################

# Visualisation avec la variable précipitation
map_pp = ggplot() + 
geom_tile(data=pp_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Précipitation (m) pour l'année 1971, région administrative de la Montérigie")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_pp,file="rasters_pp_monterigie_1971.pdf",height=6,width=12) # Export le graphique vers le dossier de travail (voir setwd())

# Visualisation avec la variable température min
map_tasmin = ggplot() + 
geom_tile(data=tasmin_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Température minimale (°C) pour l'année 1971, région administrative de la Montérigie")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_tasmin,file="rasters_tasmin_monterigie_1971.pdf",height=6,width=12)# Export le graphique vers le dossier de travail (voir setwd())

# Visualisation avec la variable température min
map_tasmax = ggplot() + 
geom_tile(data=tasmax_1971, aes(x=lon,y=lat,fill=val,color=val)) +
facet_wrap(~month_date) +
scale_fill_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_colour_manual(values = rev(brewer.pal(11,"Spectral")))+
scale_x_continuous(expand=c(0,0)) + scale_y_continuous(expand=c(0,0))+ 
ggtitle("Température maximale (°C) pour l'année 1971, région administrative de la Montérigie")+
xlab("Longitude") + ylab("Latitude") + coord_equal() + theme(legend.position="top", legend.box = "vertical",legend.title=element_blank(),plot.title = element_text(lineheight=.8, face="bold"))

ggsave(map_tasmax,file="rasters_tasmax_monterigie_1971.pdf",height=6,width=12)# Export le graphique vers le dossier de travail (voir setwd())

