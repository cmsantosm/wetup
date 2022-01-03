#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=catzip
#SBATCH --nodes=1
#SBATCH -t 5:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

sample=${1}

cd /home/csantosm/wetup/reads/wua/

zcat rmphix*/${sample}*_R1_rmphix.fq.gz > cat_rmphix/${sample}_R1_rmphix.fq
zcat rmphix*/${sample}*_R2_rmphix.fq.gz > cat_rmphix/${sample}_R2_rmphix.fq
zcat rmphix_unpaired*/${sample}*_R1_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq
zcat rmphix_unpaired*/${sample}*_R2_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq

cd /home/csantosm/wetup/reads/wua/cat_rmphix
gzip ${sample}*fq

cd /home/csantosm/wetup/reads/wua/cat_rmphix_unpaired
gzip ${sample}*fq

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
