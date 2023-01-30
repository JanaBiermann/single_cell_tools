#!/bin/bash

### Cell Ranger TCR for melanoma cohort
### Author: Jana Biermann, PhD

# provide sample name as argument
PAT=$1


#sync in
aws s3 sync s3://melanoma-ribas/raw_data/TCR-seq/${PAT}/ vol/ --quiet

cd vol

date -u > time_${PAT}_log

#execute
cellranger vdj --id=${PAT} --localcores=16 --localmem=128 \
                 --reference=/home/ubuntu/refdata-cellranger-vdj-GRCh38-alts-ensembl-7.0.0 \
                 --fastqs=/home/ubuntu/vol/ \
                 --sample=${PAT} \
                 --chain TR

date -u >> time_${PAT}.log

cd ..

#sync out
aws s3 sync /home/ubuntu/vol/${PAT}/outs/ s3://melanoma-ribas/cellranger/v7.0.0/${PAT}/ --exclude "*.fastq.gz" --quiet
