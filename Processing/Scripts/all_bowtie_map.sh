#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=bt2map
#SBATCH --nodes=1
#SBATCH -t 4:00:00
#SBATCH --ntasks=48
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

#load modules
module load bowtie2
module load samtools

path=/home/csantosm/wetup/
sample=${1}

cd ${path}all_bowtie2/all_ref

bowtie2 -x all_vibrant_drep -p 48 \
-1 ${path}reads/cat_rmphix/${sample}_R1_rmphix.fq.gz \
-2 ${path}reads/cat_rmphix/${sample}_R2_rmphix.fq.gz \
-S ${path}all_bowtie2/sam/${sample}.vib.sam \
--sensitive

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
