#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=sortmerna
#SBATCH --nodes=1
#SBATCH -t 10:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=12
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

source /home/csantosm/initconda
conda activate SORTMERNA

cd /home/csantosm/wetup/
sample=${1}

sortmerna --ref /home/csantosm/databases/sortmerna/db/silva-bac-16s-database-id85.fasta \
--ref /home/csantosm/databases/sortmerna/db/silva-arc-16s-database-id95.fasta \
--reads ./reads/cat_rmphix/${sample}_R1_rmphix.fq.gz \
--reads ./reads/cat_rmphix/${sample}_R2_rmphix.fq.gz \
--idx-dir /home/csantosm/databases/sortmerna/idx/ \
--workdir ./rrna/sort_workdir/${sample}_paired \
--aligned ./rrna/sort_results/${sample}_paired_rrna \
--fastx \
-v --threads 12

sortmerna --ref /home/csantosm/databases/sortmerna/db/silva-bac-16s-database-id85.fasta \
--ref /home/csantosm/databases/sortmerna/db/silva-arc-16s-database-id95.fasta \
--reads ./reads/cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz \
--idx-dir /home/csantosm/databases/sortmerna/idx/ \
--workdir ./rrna/sort_workdir/${sample}_unpaired_R1 \
--aligned ./rrna/sort_results/${sample}_unpaired_R1_rrna \
--fastx \
-v --threads 12

sortmerna --ref /home/csantosm/databases/sortmerna/db/silva-bac-16s-database-id85.fasta \
--ref /home/csantosm/databases/sortmerna/db/silva-arc-16s-database-id95.fasta \
--reads ./reads/cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz \
--idx-dir /home/csantosm/databases/sortmerna/idx/ \
--workdir ./rrna/sort_workdir/${sample}_unpaired_R2 \
--aligned ./rrna/sort_results/${sample}_unpaired_R2_rrna \
--fastx \
-v --threads 12

cat ./rrna/sort_results/${sample}_paired_rrna.fq \
./rrna/sort_results/${sample}_unpaired_R1_rrna.fq \
./rrna/sort_results/${sample}_unpaired_R2_rrna.fq > ./rrna/sort_cat/${sample}_all_rrna.fq

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
