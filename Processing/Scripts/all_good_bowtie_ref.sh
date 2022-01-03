#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=bt2ref
#SBATCH --nodes=1
#SBATCH -t 12:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

module load bowtie2

cd /home/csantosm/wetup/all_good_bowtie/all_good_ref/

bowtie2-build ../all.good.drep.contigs.fa all_good_vibrant_drep

#getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
