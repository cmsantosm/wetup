## The problem

The sequencing of this batch of samples was messy. Some samples had to be sequenced across 4 different runs to reach the desired depth and the number of runs needed for each samples is not the same for all of them. To approach this issue, I will generate two files with IDs, a library ID file and a sample ID file. The first one will be used for the first few scripts that perform quality-filtering. The second one will be used for assembly and any other downstream scripts. The plan is to concatenate all the clean reads after quality-filtering and then proceed as normal.

## Renaming batch 4

The last sequencing batch has a different naming convention than the rest. First, they used dashes instead of underscores. Second, they kept the barcodes. For now, we are only going to fix the dashes by renaming the files

```bash
cd /home/csantosm/wetup/reads/wub/raw4
rename -v 's/-/_/g' *
```

## Generating ID files

Note that for the 4th batch we needed to cut extra chunks to account for the barcodes in the name

```bash
cd /home/csantosm/wetup/reads/wub

ls -1 raw1/ | cut -f1,2,3,4 -d_ | sort | uniq > ../../wub1_libIDs.txt
ls -1 raw2/ | cut -f1,2,3,4 -d_ | sort | uniq > ../../wub2_libIDs.txt
ls -1 raw3/ | cut -f1,2,3,4 -d_ | sort | uniq > ../../wub3_libIDs.txt
ls -1 raw4/ | cut -f1,2,3,4,5,6 -d_ | sort | uniq > ../../wub4_libIDs.txt
```
## Generating folder structure for quality Filtering

```bash
cd /home/csantosm/wetup/reads/wub
mkdir trimmed1 trimmed2 trimmed3 trimmed4
mkdir rmphix1 rmphix2 rmphix3 rmphix4
mkdir unpaired1 unpaired2 unpaired3 unpaired4
mkdir rmphix_unpaired1 rmphix_unpaired2 rmphix_unpaired3 rmphix_unpaired4
mkdir stats1 stats2 stats3 stats4
mkdir log err
```

## Running quality Filtering

The strategy to run the program is to provide both the number of sequencing batch and the libraryID to the script. That way, there's no need to write a script per sequencing batch

```bash
for sample in $(<../wub1_libIDs.txt)
do
  sbatch --output=../reads/wub/log/${sample}.qf1.log --error=../reads/wub/err/${sample}.qf1.err wub_qual_filter.sh 1 $sample
done

for sample in $(<../wub2_libIDs.txt)
do
  sbatch --output=../reads/wub/log/${sample}.qf2.log --error=../reads/wub/err/${sample}.qf2.err wub_qual_filter.sh 2 $sample
done

for sample in $(<../wub3_libIDs.txt)
do
  sbatch --output=../reads/wub/log/${sample}.qf3.log --error=../reads/wub/err/${sample}.qf3.err wub_qual_filter.sh 3 $sample
done

for sample in $(<../wub4_libIDs.txt)
do
  sbatch --output=../reads/wub/log/${sample}.qf4.log --error=../reads/wub/err/${sample}.qf4.err wub_qual_filter.sh 4 $sample
done
```

## Generating sample ID files

To run the next scripts, I need to generate a file with all the sample ids. These sequencing runs included data from both the wetup experiment and some DNase-treated viromes from hopland. I'll process both in the wetup folder for now, but will distinguish them in their ID files.

```bash
cd /home/csantosm/wetup/reads/wub/rmphix1

ls -1 | cut -f1,2 -d_ | sort | uniq | grep WUB > ../../../wub_sampleIDs.txt
ls -1 | cut -f1,2 -d_ | sort | uniq | grep DN > ../../../hop_sampleIDs.txt
```

## Concatenating

To ease the execution of the downstream scripts, I decided to concatenate the quality-filtered reads

```bash
cd /home/csantosm/wetup/reads/wub/
mkdir cat_rmphix cat_rmphix_unpaired

for sample in $(<../../wub_sampleIDs.txt)
do
  zcat rmphix*/${sample}*_R1_rmphix.fq.gz > cat_rmphix/${sample}_R1_rmphix.fq.gz
  zcat rmphix*/${sample}*_R2_rmphix.fq.gz > cat_rmphix/${sample}_R2_rmphix.fq.gz
  zcat rmphix_unpaired*/${sample}*_R1_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz
  zcat rmphix_unpaired*/${sample}*_R2_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz
done

for sample in $(<../../hop_sampleIDs.txt)
do
  zcat rmphix*/${sample}*_R1_rmphix.fq.gz > cat_rmphix/${sample}_R1_rmphix.fq.gz
  zcat rmphix*/${sample}*_R2_rmphix.fq.gz > cat_rmphix/${sample}_R2_rmphix.fq.gz
  zcat rmphix_unpaired*/${sample}*_R1_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R1_rmphix_unpaired.fq.gz
  zcat rmphix_unpaired*/${sample}*_R2_rmphix_unpaired.fq.gz > cat_rmphix_unpaired/${sample}_R2_rmphix_unpaired.fq.gz
done

## it was taking too long so I decided to run it as a script
sbatch --output=../reads/wub/log/cat.log --error=../reads/wub/err/cat.err cat_rmphix.sh
```

## Renaming and compressing

Turns out that when you run 'zcat', the generated files are no longer compressed. However, since I saved them with the .gz extension, I need to remove it before zipping them

```bash
cd /home/csantosm/wetup/reads/wub/cat_rmphix
rename -v 's/.gz//g' *
gzip *

cd /home/csantosm/wetup/reads/wub/cat_rmphix_unpaired
rename -v 's/.gz//g' *
gzip *

## it was taking too long so I decided to run it as a script
sbatch --output=../reads/wub/log/zip.log --error=../reads/wub/err/zip.err wub_rmphix_gzip.sh

## still too slow, so I decided to run a script per sample to make things faster

cd /home/csantosm/wetup/scripts

for sample in $(</../wub_sampleIDs.txt)
do
  sbatch --output=../reads/wub/log/${sample}.zip.log --error=../reads/wub/err/${sample}.zip.err wub_rmphix_gzip_ind.sh $sample
done
```

## Performing quality check

```bash
cd /home/csantosm/wetup/fastqc
mkdir wub
cd wub
mkdir raw1 raw2 raw3 raw4 cat_rmphix err log

cd /home/csantosm/wetup/scripts

## raw files

for sample in $(<../wub1_libIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqc1.log --error=../fastqc/wub/err/${sample}.fqc1.err wub_fastqc_raw.sh raw1 $sample
done

for sample in $(<../wub2_libIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqc2.log --error=../fastqc/wub/err/${sample}.fqc2.err wub_fastqc_raw.sh raw2 $sample
done

for sample in $(<../wub3_libIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqc3.log --error=../fastqc/wub/err/${sample}.fqc3.err wub_fastqc_raw.sh raw3 $sample
done

for sample in $(<../wub4_libIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqc4.log --error=../fastqc/wub/err/${sample}.fqc4.err wub_fastqc_raw.sh raw4 $sample
done

## concatentaed rmphix files

for sample in $(<../wub_sampleIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqcr.log --error=../fastqc/wub/err/${sample}.fqcr.err wub_fastqc_cat_rmphix.sh cat_rmphix $sample
done

for sample in $(<../hop_sampleIDs.txt)
do
  sbatch --output=../fastqc/wub/log/${sample}.fqcr.log --error=../fastqc/wub/err/${sample}.fqcr.err wub_fastqc_cat_rmphix.sh cat_rmphix $sample
done
```

## Compiling fastqc results

```bash
## Repeat the following chunk for each fastqc folder within wub
cd /home/csantosm/wetup/fastqc/wub/raw1
mkdir html zip unzip
mv *.html html
mv *.zip unzip
cd unzip
for file in *
do
  unzip $file
done
mv *.zip ../zip

## Parsing
source /home/csantosm/initconda
cd /home/csantosm/wetup/
python ./scripts/fastqc_parser.py fastqc/wub/raw1/unzip/ fastqc/ wub_raw1
python ./scripts/fastqc_parser.py fastqc/wub/raw1/unzip/ fastqc/ wub_raw2
python ./scripts/fastqc_parser.py fastqc/wub/raw1/unzip/ fastqc/ wub_raw3
python ./scripts/fastqc_parser.py fastqc/wub/raw1/unzip/ fastqc/ wub_raw4
python ./scripts/fastqc_parser.py fastqc/wub/cat_rmphix/unzip/ fastqc/ wub_cat_rmphix

cd fastqc
mkdir wub_parsed
mv wub_* wub_parsed
```

## Removing intermediate files
After confirming that the quality and depth of our libraries, I need to remove all the intermediate read files that I will no longer need. These include the trimmed reads and the non concatentaed rmphix rawreads

```bash
cd /home/csantosm/wetup/reads/wub
rm trimmed*/*
rm rmphix*/*
rm unpaired*/*
```

## Running megahit
```bash
for sample in $(<../wub_sampleIDs.txt)
do
  sbatch --output=../megahit/log/${sample}.mh.log --error=../megahit/err/${sample}.mh.err wub_megahit.sh  $sample
done

# Some samples needed more memory so I reran them with a new script

sbatch --output=../megahit/log/WUB_TM06.mh.log --error=../megahit/err/WUB_TM06.mh.err wub_megahit_mem.sh  WUB_TM06

sbatch --output=../megahit/log/WUB_TM14.mh.log --error=../megahit/err/WUB_TM14.mh.err wub_megahit_mem.sh  WUB_TM14

sbatch --output=../megahit/log/WUB_TM20.mh.log --error=../megahit/err/WUB_TM20.mh.err wub_megahit_mem.sh  WUB_TM20

sbatch --output=../megahit/log/WUB_TM32.mh.log --error=../megahit/err/WUB_TM32.mh.err wub_megahit_mem.sh  WUB_TM32

sbatch --output=../megahit/log/WUB_TM34.mh.log --error=../megahit/err/WUB_TM34.mh.err wub_megahit_mem.sh  WUB_TM34

sbatch --output=../megahit/log/WUB_TM37.mh.log --error=../megahit/err/WUB_TM37.mh.err wub_megahit_mem.sh  WUB_TM37

sbatch --output=../megahit/log/WUB_TM39.mh.log --error=../megahit/err/WUB_TM39.mh.err wub_megahit_mem.sh  WUB_TM39

# Some scripts became suspended after another user started a job in the same node. I cancelled the jobs and restarted the scripts

sbatch --output=../megahit/log/WUB_TM01.mh2.log --error=../megahit/err/WUB_TM01.mh2.err wub_megahit.sh  WUB_TM01

sbatch --output=../megahit/log/WUB_VD36.mh2.log --error=../megahit/err/WUB_VD36.mh2.err wub_megahit.sh  WUB_VD36

sbatch --output=../megahit/log/WUB_VD45.mh2.log --error=../megahit/err/WUB_VD45.mh2.err wub_megahit.sh  WUB_VD45

sbatch --output=../megahit/log/WUB_VN01.mh2.log --error=../megahit/err/WUB_VN01.mh2.err wub_megahit.sh  WUB_VN01

# For one sample, the time alloted was not enough so I had to rerun the script for it to finish

sbatch --output=../megahit/log/WUB_TM39.mh2.log --error=../megahit/err/WUB_TM39.mh2.err wub_megahit_mem.sh  WUB_TM39
```

## Renaming

```bash
cd /home/csantosm/wetup/megahit
cp WUB*/WUB*contigs.fa contigs
cd contigs

module load bbmap

for sample in $(<../../wub_sampleIDs.txt)
do
  rename.sh in=${sample}.contigs.fa out=${sample}.renamed.contigs.fa prefix=${sample}_contig_
  stats.sh in=${sample}.renamed.contigs.fa gc=${sample}.megahit.stats.txt gcformat=1
done
```

## Filtering

```bash
for sample in $(<../../wub_sampleIDs.txt)
do
  perl ../../scripts/removesmalls.pl 10000 ${sample}.renamed.contigs.fa > 10k.${sample}.renamed.contigs.fa
done

mv 10k* ../10k_contigs
mv *stats.txt ../stats
mv *renamed* ../renamed_contigs
```

## VIBRANT

```bash
/home/csantosm/wetup

cat wub_sampleIDs.txt | grep TM > wub_tmgIDs.txt
cat wub_sampleIDs.txt | grep WUB_V > wub_virIDs.txt

cd scripts

for sample in $(<../wub_virIDs.txt)
do
  sbatch --output=../vibrant/log/${sample}.vbrnt.log --error=../vibrant/err/${sample}.vbrnt.err vibrant.sh $sample
done

for sample in $(<../wub_tmgIDs.txt)
do
  sbatch --output=../vibrant/log/${sample}.vbrnt.log --error=../vibrant/err/${sample}.vbrnt.err vibrant_tmg.sh $sample
done
```

## Separating into groups based on soil source and profiling method

```bash
cd /home/csantosm/wetup/vibrant

cat WUB*/VIBRAN*/VIBRANT_phages*/*phages_combined.fna > wub.all.vib.contigs.fna
grep ">" wub.all.vib.contigs.fna > wub.all.vib.ids

grep -f ../hopTM.txt wub.all.vib.ids | cut -f2 -d">" > hopTM.ids
grep -f ../mclTM.txt wub.all.vib.ids | cut -f2 -d">" > mclTM.ids
grep -f ../hopVD.txt wub.all.vib.ids | cut -f2 -d">" > hopVD.ids
grep -f ../mclVD.txt wub.all.vib.ids | cut -f2 -d">" > mclVD.ids
grep -f ../hopVN.txt wub.all.vib.ids | cut -f2 -d">" > hopVN.ids
grep -f ../mclVN.txt wub.all.vib.ids | cut -f2 -d">" > mclVN.ids

source /home/csantosm/initconda
conda activate BIOPYTHON
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopTM.ids > hopTM.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclTM.ids > mclTM.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopVD.ids > hopVD.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVD.ids > mclVD.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopVN.ids > hopVN.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVN.ids > mclVN.contigs.fna

cd /home/csantosm/wetup/drep
mkdir hopTM mclTM hopVD mclVD hopVN mclVN
mv ../vibrant/hopTM.contigs.fna hopTM
mv ../vibrant/mclTM.contigs.fna mclTM
mv ../vibrant/hopVD.contigs.fna hopVD
mv ../vibrant/mclVD.contigs.fna mclVD
mv ../vibrant/hopVN.contigs.fna hopVN
mv ../vibrant/mclVN.contigs.fna mclVN

cd hopTM
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../mclTM
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../hopVD
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../mclVD
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../hopVN
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../mclVN
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
```

## Running drep

Last time many of the subsets didn't run because the memory run out. I will just ask for more resources for the VD files (mem = 400) and hope that it'll be enough. The rest wil be performed with just mem=32GB Otherwise I'll have to split and conquer again.

```bash
cd /home/csantosm/wetup/scripts
sbatch --output=../drep/log/hopTM.drep.log --error=../drep/err/hopTM.drep.log drep.sh hopTM
sbatch --output=../drep/log/mclTM.drep.log --error=../drep/err/mclTM.drep.log drep.sh mclTM
sbatch --output=../drep/log/hopVN.drep.log --error=../drep/err/hopVN.drep.log drep.sh hopVN
sbatch --output=../drep/log/mclVN.drep.log --error=../drep/err/mclVN.drep.log drep.sh mclVN
sbatch --output=../drep/log/hopVD.drep.log --error=../drep/err/hopVD.drep.log drep_mem.sh hopVD
sbatch --output=../drep/log/mclVD.drep.log --error=../drep/err/mclVD.drep.log drep_mem.sh mclVD
```

## Running the original dRep script  failed for hopVD and mclVD. I ended up separating into groups first. The number of sequences per group depended on how big the original files were. I divided Hopland into 3 and McLaughlin into 4 groups

```bash
cd /home/csantosm/wetup/vibrant
split -l 18300 hopVD.ids hopVD.
split -l 16820 mclVD.ids mclVD.

source /home/csantosm/initconda
conda activate BIOPYTHON

python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopVD.aa > hopVD.aa.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopVD.ab > hopVD.ab.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna hopVD.ac > hopVD.ac.contigs.fna

python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVD.aa > mclVD.aa.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVD.ab > mclVD.ab.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVD.ac > mclVD.ac.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py wub.all.vib.contigs.fna mclVD.ad > mclVD.ad.contigs.fna
```

```bash
cd /home/csantosm/wetup/drep
mkdir hopVD.aa hopVD.ab hopVD.ac mclVD.aa mclVD.ab mclVD.ac mclVD.ad

mv ../vibrant/hopVD.aa.contigs.fna hopVD.aa
mv ../vibrant/hopVD.ab.contigs.fna hopVD.ab
mv ../vibrant/hopVD.ac.contigs.fna hopVD.ac

mv ../vibrant/mclVD.aa.contigs.fna mclVD.aa
mv ../vibrant/mclVD.ab.contigs.fna mclVD.ab
mv ../vibrant/mclVD.ac.contigs.fna mclVD.ac
mv ../vibrant/mclVD.ad.contigs.fna mclVD.ad


cd hopVD.aa
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
cd ../hopVD.ab
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
cd ../hopVD.ac
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd ../mclVD.aa
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
cd ../mclVD.ab
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
cd ../mclVD.ac
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs
cd ../mclVD.ad
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd /home/csantosm/wetup/scripts

## I had to update the memory requirements to 64GB for the hopland scripts because they failed the first time I ran them with 32GB. The McLaughlin scripts worked fine with 32GB

sbatch --output=../drep/log/hopVD.aa.drep.log --error=../drep/err/hopVD.aa.drep.err drep.sh hopVD.aa
sbatch --output=../drep/log/hopVD.ab.drep.log --error=../drep/err/hopVD.ab.drep.err drep.sh hopVD.ab
sbatch --output=../drep/log/hopVD.ac.drep.log --error=../drep/err/hopVD.ac.drep.err drep.sh hopVD.ac

sbatch --output=../drep/log/mclVD.aa.drep.log --error=../drep/err/mclVD.aa.drep.err drep.sh mclVD.aa
sbatch --output=../drep/log/mclVD.ab.drep.log --error=../drep/err/mclVD.ab.drep.err drep.sh mclVD.ab
sbatch --output=../drep/log/mclVD.ac.drep.log --error=../drep/err/mclVD.ac.drep.err drep.sh mclVD.ac
sbatch --output=../drep/log/mclVD.ad.drep.log --error=../drep/err/mclVD.ad.drep.err drep.sh mclVD.ad
```

```bash
cd /home/csantosm/wetup/drep
rm -r hopVD/
rm -r mclVD/

mkdir hopVD mclVD

mkdir hopVD/split_contigs
cp hopVD.a*/*dRep/dereplicated_genomes/* hopVD/split_contigs

mkdir mclVD/split_contigs
cp mclVD.a*/*dRep/dereplicated_genomes/* mclVD/split_contigs

cd /home/csantosm/wetup/scripts
sbatch --output=../drep/log/hopVD.drep.log --error=../drep/err/hopVD.drep.err drep_mem.sh hopVD
sbatch --output=../drep/log/mclVD.drep.log --error=../drep/err/mclVD.drep.err drep_mem.sh mclVD
```

```bash
cd /home/csantosm/wetup/drep
mkdir hop mcl

mkdir hop/split_contigs
cp hopVD/*dRep/dereplicated_genomes/* hop/split_contigs
cp hopVN/*dRep/dereplicated_genomes/* hop/split_contigs
cp hopTM/*dRep/dereplicated_genomes/* hop/split_contigs

mkdir mcl/split_contigs
cp mclVD/*dRep/dereplicated_genomes/* mcl/split_contigs
cp mclVN/*dRep/dereplicated_genomes/* mcl/split_contigs
cp mclTM/*dRep/dereplicated_genomes/* mcl/split_contigs

cd /home/csantosm/wetup/scripts
sbatch --output=../drep/log/hop.drep.log --error=../drep/err/hop.drep.err drep_mem.sh hop
sbatch --output=../drep/log/mcl.drep.log --error=../drep/err/mcl.drep.err drep_mem.sh mcl
```

```bash
cd /home/csantosm/wetup/drep
mkdir all

mkdir all/split_contigs
cp hop/*dRep/dereplicated_genomes/* all/split_contigs
cp mcl/*dRep/dereplicated_genomes/* all/split_contigs
cp bot/*dRep/dereplicated_genomes/* all/split_contigs
cp top/*dRep/dereplicated_genomes/* all/split_contigs

## mem=600GB
cd /home/csantosm/wetup/scripts
sbatch --output=../drep/log/all.drep.log --error=../drep/err/all.drep.err drep_mem.sh all

```

##

```bash
cd /home/csantosm/wetup/vibrant
cat W*/*/VIBRANT_phages*/*phages_combined.fna > all.vib.contigs.fna
grep 'circular\|high\|medium' W*/*/VIBRANT_results*/VIBRANT_genome_quality_* | cut -f1 | cut -f2 -d: | sort | uniq > good.vib.ids

source /home/csantosm/wetup/initconda
conda activate BIOPYTHON
python ../scripts/filter_fasta_by_list_of_headers.py all.vib.contigs.fna good.vib.ids > good.vib.contigs.fna

cat botTM.ids botVD.ids botVN.ids > bot.ids
cat topTM.ids topVD.ids topVN.ids > top.ids
cat hopTM.ids hopVD.ids hopVN.ids > hop.ids
cat mclTM.ids mclVD.ids mclVN.ids > mcl.ids

python ../scripts/filter_fasta_by_list_of_headers.py good.vib.contigs.fna bot.ids > bot.good.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py good.vib.contigs.fna top.ids > top.good.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py good.vib.contigs.fna hop.ids > hop.good.contigs.fna
python ../scripts/filter_fasta_by_list_of_headers.py good.vib.contigs.fna mcl.ids > mcl.good.contigs.fna

cd /home/csantosm/wetup/drep
mkdir bot_good top_good hop_good mcl_good

mv ../vibrant/bot.good.contigs.fna bot_good
mv ../vibrant/top.good.contigs.fna top_good
mv ../vibrant/hop.good.contigs.fna hop_good
mv ../vibrant/mcl.good.contigs.fna mcl_good

cd /home/csantosm/wetup/drep/bot_good
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd /home/csantosm/wetup/drep/top_good
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd /home/csantosm/wetup/drep/hop_good
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd /home/csantosm/wetup/drep/mcl_good
awk '/^>/ {OUT=substr($0,2) ".fa"}; OUT {print >OUT}' *.fna
mkdir split_contigs
mv W* split_contigs

cd /home/csantosm/wetup/scripts

sbatch --output=../drep/log/bot.good.aa.drep.log --error=../drep/err/bot.good.aa.drep.err drep.sh bot_good
sbatch --output=../drep/log/top.good.aa.drep.log --error=../drep/err/top.good.aa.drep.err drep.sh top_good
sbatch --output=../drep/log/hop.good.aa.drep.log --error=../drep/err/hop.good.aa.drep.err drep.sh hop_good
sbatch --output=../drep/log/mcl.good.aa.drep.log --error=../drep/err/mcl.good.aa.drep.err drep.sh mcl_good
```

## dRep

```bash
cd /home/csantosm/wetup/drep
mkdir all_good
mkdir all_good/split_contigs

cp hop_good/*dRep/dereplicated_genomes/* all_good/split_contigs
cp mcl_good/*dRep/dereplicated_genomes/* all_good/split_contigs
cp bot_good/*dRep/dereplicated_genomes/* all_good/split_contigs
cp top_good/*dRep/dereplicated_genomes/* all_good/split_contigs

cd /home/csantosm/wetup/scripts
sbatch --output=../drep/log/all.good.drep.log --error=../drep/err/all.good.drep.err drep.sh all_good
```

## concatenating the WUA samples

```bash
cd /home/csantosm/wetup/scripts
for sample in $(<../wua_sampleIDs.txt)
do
  sbatch --output=../reads/wua/log/${sample}.catzip.log --error=../reads/wua/err/${sample}.catzip.err wua_cat_zip.sh $sample
done
```

## bowtie ref

```bash
cd /home/csantosm/wetup/
mkdir all_good_bowtie
cd all_good_bowtie
mkdir err log bam sam
cat ../drep/all_good/all_good_dRep/dereplicated_genomes/* > all.good.drep.contigs.fa
```

```bash
cd /home/csantosm/wetup/all_good_bowtie
mkdir all_good_ref

cd /home/csantosm/wetup/scripts
sbatch --output=../all_good_bowtie/log/all.good.ref.log --error=../all_good_bowtie/err/all.good.ref.err all_good_bowtie_ref.sh
 ```

## bowtie map

 ```bash
cd /home/csantosm/wetup/scripts

for sample in $(<../sampleIDs.txt)
do
  sbatch --output=../all_good_bowtie/log/${sample}.all.good.bt2.log --error=../all_good_bowtie/err/${sample}.jep.all.gooderr all_good_bowtie_map.sh $sample
done
```

## samtools

 ```bash

 cd /home/csantosm/wetup/scripts

 for sample in $(<../sampleIDs.txt)
 do
   sbatch --output=../all_good_bowtie/log/${sample}.all.good.sam.log --error=../all_good_bowtie/err/${sample}.all.good.sam.err all_good_samtools.sh $sample
 done
 ```

## coverM
```bash
cd /home/csantosm/wetup/all_good_bowtie/
mv sam/*bam* bam

cd /home/csantosm/wetup/scripts
sbatch --output=../all_good_bowtie/log/all.good.coverm.log --output=../all_good_bowtie/err/all.good.coverm.err all_good_coverm.sh
```

## sortmeRNA

```bash
cd /home/csantosm/wetup/
mkdir rrna
cd rrna
mkdir err log rdp sort_cat sort_results sort_workdir

cd /home/csantosm/wetup/scripts

for sample in $(<../sampleIDs.txt)
do
  sbatch --output=../rrna/log/${sample}.sortme.log --error=../rrna/err/${sample}.sortme.err all_sortmerna.sh $sample
done


for sample in $(<../sampleIDs.txt)
do
  sbatch --output=../rrna/log/${sample}.rdpc.log --error=../rrna/err/${sample}.rdpc.err rdp_classify.sh $sample
done

sbatch --output=../rrna/log/jep.rdpm.log --error=../rrna/err/jep.rdpm.err rdp_merge.sh
```
