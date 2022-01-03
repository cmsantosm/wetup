#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=cat
#SBATCH --nodes=1
#SBATCH -t 1:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

cd /home/csantosm/wetup/reads/wub/cat_rmphix
gzip *

cd /home/csantosm/wetup/reads/wub/cat_rmphix_unpaired
gzip *

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
