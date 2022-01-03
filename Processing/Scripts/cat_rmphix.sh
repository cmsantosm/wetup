#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=cat
#SBATCH --nodes=1
#SBATCH -t 48:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

cd /home/csantosm/wetup/reads/wub/

for sample in $(<../../wub_sampleIDs.txt)
do
  zcat rmphix*/${sample}*_R1_rmphix.fq.gz > cat_rmphix/${sample}_R1_rmphix.fq.gz
  zcat rmphix*/${sample}*_R2_rmphix.fq.gz > cat_rmphix/${sample}_R2_rmphix.fq.gz
  zcat rmphix_unpaired*/${sample}*_R1_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz
  zcat rmphix_unpaired*/${sample}*_R2_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz
done

for sample in $(<../../hop_sampleIDs.txt)
do
  zcat rmphix*/${sample}*_R1_rmphix.fq.gz > cat_rmphix/${sample}_R1_rmphix.fq.gz
  zcat rmphix*/${sample}*_R2_rmphix.fq.gz > cat_rmphix/${sample}_R2_rmphix.fq.gz
  zcat rmphix_unpaired*/${sample}*_R1_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz
  zcat rmphix_unpaired*/${sample}*_R2_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz
done

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
