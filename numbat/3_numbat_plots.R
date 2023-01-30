#!/usr/bin/Rscript

#### Title: Numbat plots
#### Author: Jana Biermann, PhD

library(numbat)
library(dplyr)
library(Seurat)
library(ggplot2)
library(glue)
library(data.table)
library(ggtree)
library(stringr)
library(tidygraph)
library(patchwork)


# Provide sample name as argument
pat<- commandArgs()[6]

mypal = c('1' = 'gray', '2' = "#377EB8", '3' = "#4DAF4A", '4' = "#984EA3", 
          '5'="#ff9768", '6'='#ae1717', '7'='#0f04b5', '8'="#f87382",
          '9'='green','10'='yellow','11'='deeppink')

# Read-in numbat output
nb = Numbat$new(out_dir = paste0('data/',pat))

# Sync-in sample Seurat object from AWS
system(paste0("aws s3 sync s3://XYZ/data_",pat,"/ data/",pat,"/ --exclude '*' --include '*.rds' --quiet"))
seu<- readRDS(paste0("data/",pat,"/data_",pat,".rds"))


# Single-cell CNV calls
cnv_calls<- nb$joint_post %>% select(cell, CHROM, seg, cnv_state, p_cnv, p_cnv_x, p_cnv_y)
table(cnv_calls$cnv_state)
cnv_calls %>% group_by(cnv_state) %>% arrange(p_cnv,desc=F)

# Clone info
clones<-dim(table(nb$clone_post$clone_opt))
clone_info<-nb$clone_post
seu$cell<-seu$barcode_orig
seu@meta.data<-left_join(seu@meta.data,clone_info,by='cell')
rownames(seu@meta.data)<-seu$barcode_orig

### Plots
pdf(paste0("data/",pat,"/plots_",pat,"_numbat.pdf"),width = 10)
# Copy number landscape and single-cell phylogeny
nb$plot_phylo_heatmap(clone_bar = TRUE, p_min = 0.9,raster = T,pal_clone = mypal)

# Consensus copy number segments
nb$plot_consensus()

# Bulk CNV profiles
nb$bulk_clones %>% 
  filter(n_cells > 50) %>%
  plot_bulks(min_LLR = 10, # filtering CNVs by evidence
             legend = TRUE,raster=T)

# clones
DimPlot(seu, group.by = 'clone_opt',shuffle = T, raster=T,cols = mypal[1:clones])
DimPlot(seu, group.by = 'GT_opt',shuffle = T, raster=T)

# Tumor versus normal probability
FeaturePlot(seu, features  = c('p_cnv','p_cnv_x','p_cnv_y'),order = T, raster=T)&
  scale_color_gradient2(low = 'royalblue', mid = 'white', high = 'red3', midpoint = 0.5, limits = c(0,1), name = 'Posterior')&
  ggtitle('Tumor vs normal probability\n(joint, gex, allele)')

# Tumor phylogeny
nb$plot_sc_tree(
  label_size = 3, 
  branch_width = 0.5, 
  tip_length = 0.5,
  pal_clone = mypal,
  tip = TRUE)

# mutational history
nb$plot_mut_history(pal=mypal)
dev.off()

