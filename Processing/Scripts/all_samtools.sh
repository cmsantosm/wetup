#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=samtools
#SBATCH --nodes=1
#SBATCH -t 2:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

module load samtools

sample=${1}
cd /home/csantosm/wetup/all_bowtie2/sam/


samtools view -F 4 -bS ${sample}.vib.sam | samtools sort > ${sample}.vib.sI.bam
samtools index ${sample}.vib.sI.bam

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
