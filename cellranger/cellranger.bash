#!/bin/bash

### Cell Ranger for melanoma cohort
### Author: Jana Biermann, PhD

# provide sample name as argument
PAT=$1


#sync in
aws s3 sync s3://melanoma-ribas/raw_data/snRNA-seq/${PAT}/ vol/ --quiet

cd vol

date -u > time_${PAT}.log

#execute
cellranger count --id=${PAT} --localcores=16 --localmem=128 \
                 --transcriptome=/home/ubuntu/refdata-gex-GRCh38-2020-A \
                 --fastqs=/home/ubuntu/vol/ --sample=${PAT} \
                 --chemistry SC5P-PE


date -u >> time_${PAT}.log

cd ..

#sync out
aws s3 sync /home/ubuntu/vol/${PAT}/outs/ s3://melanoma-ribas/cellranger/v7.0.0/${PAT}/ --exclude "*.fastq.gz" --quiet
