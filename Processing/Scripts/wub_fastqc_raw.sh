#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=fastqc
#SBATCH --nodes=1
#SBATCH -t 2:00:00
#SBATCH --ntasks=8
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

# loading modules
module load fastqc

# running commands
path=/home/csantosm/wetup/
folder=${1}
library=${2}

fastqc -t 8 -o ${path}fastqc/wub/${folder} ${path}reads/wub/${folder}/${library}_R1_001.fastq.gz
fastqc -t 8 -o ${path}fastqc/wub/${folder} ${path}reads/wub/${folder}/${library}_R2_001.fastq.gz

# finished commands

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
