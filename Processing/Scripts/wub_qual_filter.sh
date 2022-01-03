#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=qual_filt
#SBATCH --nodes=1
#SBATCH --time=04:00:00
#SBATCH --ntasks=8
#SBATCH --mem=32GB
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

# loading modules
module load bbmap
source /home/csantosm/initconda
conda activate TRIMMOMATIC

# running commands
path=/home/csantosm/wetup/reads/wub/
folder=${1}
sample=${2}

trimmomatic PE -threads 8 -phred33 \
  ${path}raw${folder}/${sample}_R1_001.fastq.gz ${path}raw${folder}/${sample}_R2_001.fastq.gz \
  ${path}trimmed${folder}/${sample}_R1_trimmed.fq.gz ${path}unpaired${folder}/${sample}_R1_unpaired.fq.gz \
  ${path}trimmed${folder}/${sample}_R2_trimmed.fq.gz ${path}unpaired${folder}/${sample}_R2_unpaired.fq.gz \
  ILLUMINACLIP:/home/csantosm/databases/TruSeq3-PE.fa:2:30:10 \
  SLIDINGWINDOW:4:30 MINLEN:50

  bbduk.sh \
    in1=${path}trimmed${folder}/${sample}_R1_trimmed.fq.gz \
    in2=${path}trimmed${folder}/${sample}_R2_trimmed.fq.gz \
    out1=${path}rmphix${folder}/${sample}_R1_rmphix.fq.gz \
    out2=${path}rmphix${folder}/${sample}_R2_rmphix.fq.gz \
    ref=/home/csantosm/databases/phix174_ill.ref.fa \
    k=31 \
    hdist=1 \
    stats=${path}stats${folder}/${sample}_stats.txt \
    -Xmx20g

  bbduk.sh \
    in=${path}unpaired${folder}/${sample}_R1_unpaired.fq.gz \
    out=${path}rmphix_unpaired${folder}/${sample}_R1_rmphix_unpaired.fq.gz \
    ref=/home/csantosm/databases/phix174_ill.ref.fa \
    k=31 \
    hdist=1 \
    stats=${path}stats${folder}/${sample}_R1_stats.txt \
    -Xmx20g

  bbduk.sh \
    in=${path}unpaired${folder}/${sample}_R2_unpaired.fq.gz \
    out=${path}rmphix_unpaired${folder}/${sample}_R2_rmphix_unpaired.fq.gz \
    ref=/home/csantosm/databases/phix174_ill.ref.fa \
    k=31 \
    hdist=1 \
    stats=${path}stats${folder}/${sample}_R2_stats.txt \
    -Xmx20g

# finished commands

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
