#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=megahit
#SBATCH --nodes=1
#SBATCH -t 48:00:00
#SBATCH --ntasks=24
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

# loading modules
source /home/csantosm/initconda
conda activate MEGAHIT

# move to rawreads folder
cd /home/csantosm/wetup/reads/wub/
sample=${1}

megahit -1 ./cat_rmphix/${sample}_R1_rmphix.fq.gz \
-2 ./cat_rmphix/${sample}_R2_rmphix.fq.gz \
-r ./cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz,./cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz \
-o ../../megahit/${sample} \
--out-prefix ${sample} \
--min-contig-len 1000 --presets meta-large \
-t 24 --continue

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
