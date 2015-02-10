#' ---
#' title: "BIOST 578 Homework 1"
#' author: "Marea Cobb"
#' date: "February 9, 2015"
#' reviewer: Gloria Chi""
#' ---

#' Loads specific libraries
library("knitr")
suppressMessages(library(GEOmetadb))
library(data.table)


#' Creates the R markdown files.
opts_knit$set(progress = FALSE, verbose = FALSE, message=FALSE)
spin(hair = "CobbMareaHW2.R", format = "Rmd")
file.rename("CobbMareaHW2.md", "CobbMareaHW2.Rmd")


## This will download the entire database, so can be slow
if (!file.exists("GEOmetadb.sqlite")) {
  # Download database only if it's not done already
  getSQLiteFile()
}

# Connects to GEOmetadb
geo_con <- dbConnect(SQLite(), "GEOmetadb.sqlite")


# Queries the database for gene expression data submitted by Yale using the Illumina platform looking at HCV using sqlite..
query<-"SELECT gse.title, gse.gse, gpl.gpl, gpl.manufacturer, gpl.title
        FROM (gse JOIN gse_gpl ON gse.gse=gse_gpl.gse) j
        JOIN gpl ON j.gpl=gpl.gpl 
        WHERE gpl.manufacturer LIKE '%Illumina%'
        AND gse.contact LIKE '%yale%'
        AND gse.title LIKE '%HCV%';"

# Queries the database for gene expression data submitted by Yale using the Illumina platform looking at HCV using data.tables instead of sqlite.
res <- dbGetQuery(geo_con, query)
res

#Queries the datab
query_dt<-merge(data.table(dbGetQuery(geo_con, 
                      "SELECT gse FROM gse WHERE contact LIKE '%yale%' AND title LIKE '%HCV%';"), key="gse"), (merge(data.table(dbGetQuery(geo_con,
                      "SELECT gpl, manufacturer, title FROM gpl WHERE manufacturer LIKE '%Illumina%';"), key="gpl"), data.table(dbGetQuery(geo_con, 
                      "SELECT * FROM gse_gpl;"), key=c("gse", "gpl")), by="gpl")), by="gse")
query_dt

# Disconnects from the database
dbDisconnect(geo_con)
