#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=cat
#SBATCH --nodes=1
#SBATCH -t 2:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

sample=${1}

cd /home/csantosm/wetup/reads/wub/cat_rmphix
gzip ${sample}*fq

cd /home/csantosm/wetup/reads/wub/cat_rmphix_unpaired
gzip ${sample}*fq

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
