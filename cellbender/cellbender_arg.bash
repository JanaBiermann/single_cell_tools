#!/bin/bash

### Cell Ranger for melanoma cohort
### Author: Jana Biermann, PhD

# provide sample name and total-droplets-included as arguments
pat=$1
drop=$2

aws s3 sync s3://melanoma-ribas/cellranger/v7.0.0/${pat}/ data/${pat}/ --exclude '*' --include 'raw_feature_bc_matrix.h5' --quiet
aws s3 sync s3://melanoma-ribas/cellranger/v7.0.0/${pat}/ data/${pat}/ --exclude "*" --include "metrics_summary.csv"

Rscript single_cell_tools/cellbender/get_number_of_cells.R ${pat}
cells=`cat data/${pat}/nCells.txt`

cellbender remove-background \
                 --input data/${pat}/raw_feature_bc_matrix.h5 \
                 --output data/${pat}/${pat}.h5 \
                 --expected-cells ${cells} \
                 --total-droplets-included ${drop} \
                 --cuda \
                 --epochs 300

rm data/${pat}/nCells.txt
rm data/${pat}/metrics_summary.csv

aws s3 sync data/${pat}/ s3://melanoma-ribas/cellbender/${pat}/ --exclude "*.out" --exclude '*.err' --exclude 'raw_feature*' --exclude '.*' --quiet
