#!/usr/bin/env Rscript

#### Get number of cells for CellBender input
#### Author: Jana Biermann, PhD

pat <- commandArgs()[6]

tab<-read.csv(paste0("data/",pat,"/metrics_summary.csv"))
val<-as.numeric(as.numeric(gsub(",", "", tab[1,1])))
write.table(val,paste0("data/",pat,"/nCells.txt"),col.names = F,row.names = F)
