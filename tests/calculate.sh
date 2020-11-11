#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Jenkins seems to have different locale, so sort is off. Set it explicitly
export LC_ALL=en_US.utf8

cd $1

# Result files have PREFIX_FOLDERNAME added to all output files
# This is ignored and file extensions are used to identify the files to calculate

# grep removes metadata that changes each time it is run
# vcf sorting is not deterministic (make it so with sort)
cat *.fail.vcf | grep -vE "(##cmdline|##fileDate)" | sort -t \t | md5sum
cat *.merged.vcf | grep -vE "(##cmdline|##fileDate)" | sort -t \t | md5sum
cat *.pass.vcf | grep -vE "(##cmdline|##fileDate)" | sort -t \t | md5sum
cat *.primers.vcf | grep -vE "(##cmdline|##fileDate)" | sort -t \t | md5sum

cat *.consensus.fasta | md5sum
cat *.muscle.out.fasta | md5sum

# Exclude BAM files with nCoV-2019 as they are not part of output
module load samtools/1.9 >/dev/null 2>&1
for i in *.sorted.bam
do
  if echo "$i" | grep -vq nCoV-2019; then
    samtools view "$i" | md5sum
  fi
done

cat test.qc.csv | md5sum
