#!/bin/bash
#SBATCH -D /home/csantosm/wetup/scripts/
#SBATCH --job-name=coverm
#SBATCH --nodes=1
#SBATCH -t 10:00:00
#SBATCH --ntasks=1
#SBATCH --partition=bmm

# for calculating the amount of time the job takes
begin=`date +%s`
echo $HOSTNAME

cd /home/csantosm/software/coverm-x86_64-unknown-linux-musl-0.6.1/
path=/home/csantosm/wetup/all_good_bowtie/bam/

./coverm contig -m mean -b ${path}*.bam > ${path}all.good.mean.tsv
./coverm contig -m mean --min-covered-fraction 0.75 -b ${path}*.bam > ${path}all.good.75.mean.tsv

./coverm contig -m trimmed_mean -b ${path}*.bam > ${path}all.good.tmean.tsv
./coverm contig -m trimmed_mean --min-covered-fraction 0.75 -b ${path}*.bam > ${path}all.good.75.tmean.tsv

./coverm contig -m count -b ${path}*.bam > ${path}all.good.count.tsv
./coverm contig -m count --min-covered-fraction 0.75 -b ${path}*.bam > ${path}all.good.75.count.tsv

./coverm contig -m covered_fraction -b ${path}*.bam > ${path}all.good.cf.tsv

# getting end time to calculate time elapsed
end=`date +%s`
elapsed=`expr $end - $begin`
echo Time taken: $elapsed
