# ncov2019ArticNfNanopore

This Nextflow pipeline automates the ARTIC network nCoV-2019 novel coronavirus bioinformatics protocol. It will turn SARS-COV2 sequencing data (Illumina or Nanopore) into consensus sequences and provide other helpful outputs to assist the project's sequencing centres with submitting data. Pipeline documentation at https://artic.readthedocs.io/en/latest/minion/.

## Overview

## Dependencies

* [ncov2019-artic-nf-nanopore 20200926](https://github.com/connor-lab/ncov2019-artic-nf)
* [artic-ncov2019-primer-schemes 20200908](https://github.com/artic-network/primer-schemes)


## Usage

### Cromwell
```
java -jar cromwell.jar run ncov2019ArticNfNanopore.wdl --inputs inputs.json
```

### Inputs

#### Required workflow parameters:
Parameter|Value|Description
---|---|---
`method`|String|Either nanopolish or medaka.
`prefix`|String|String prepended to output files.
`basecalledFastq`|String|A directory containing basecalled fastqs. This is the output directory from guppy_barcoder or guppy_basecaller - usually fastq_pass. This can optionally contain barcodeXX directories, which are auto-detected.
`fast5Path`|String|Directory containing the fast5 files.
`sequencingSummary`|File|The path to the sequencing_summary.txt produced by guppy.


#### Optional workflow parameters:
Parameter|Value|Default|Description
---|---|---|---
`profile`|String?|None|Optional. May be conda,singularity,docker,slurm,lsf.


#### Optional task parameters:
Parameter|Value|Default|Description
---|---|---|---
`runNcov2019ArticNfNanopore.modules`|String|"ncov2019-artic-nf-nanopore/20200926 artic-ncov2019-primer-schemes/20200908"|Modules to load in modulator.
`runNcov2019ArticNfNanopore.ncov2019ArticNextflowPath`|String|"$NCOV2019_ARTIC_NF_NANOPORE_ROOT"|Path to Nextflow workflow loaded by ncov2019-artic-nf-nanopore module. To download the most current remote repo use connor-lab/ncov2019-artic-nf
`runNcov2019ArticNfNanopore.schemeRepoURL`|String|"$ARTIC_NCOV2019_PRIMER_SCHEMES_ROOT"|Repo to download your primer scheme from. Loaded locally using environemntal variable set by artic-ncov2019-primer-schemes module.
`runNcov2019ArticNfNanopore.schemeDir`|String?|None|Directory within schemeRepoURL that contains primer schemes. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config
`runNcov2019ArticNfNanopore.schemeName`|String?|None|Directory within schemeDir that contains ncov2019 primer schema. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config
`runNcov2019ArticNfNanopore.schemeVersion`|String?|None|Version of primer schema to use. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config
`runNcov2019ArticNfNanopore.additionalParameters`|String?|None|Any additional parameters that need to be passed to the Nextflow workflow
`runNcov2019ArticNfNanopore.threads`|Int|4|Requested CPU threads.
`runNcov2019ArticNfNanopore.jobMemory`|Int|8|Memory (GB) allocated for this job.
`runNcov2019ArticNfNanopore.timeout`|Int|4|Number of hours before task timeout.


### Outputs

Output | Type | Description
---|---|---
`bamRaw`|File|The raw alignment of sample reads to reference genome
`bamRawIndex`|File|The BAM index for the raw alignments BAM
`bamPrimerTrimmed`|File|BAM file for visualisation after primer-binding site trimming
`bamPrimerTrimmedIndex`|File|BAM index file for visualisation after primer-binding site trimming
`bamTrimmed`|File|BAM file with the primers left on (used in variant calling)
`bamTrimmedIndex`|File|BAM index file with the primers left on (used in variant calling)
`fastaConcensus`|File|Consensus sequence
`fastaMuscle`|File|An alignment of the consensus sequence against the reference sequence
`qcCsv`|File|QC summary
`vcfFail`|File|Detected variants in VCF format failing quality filter
`vcfMerged`|File|All detected variants in VCF format
`vcfPass`|File|Detected variants in VCF format passing quality filter (gz compressed)
`vcfPrimers`|File|Detected variants falling in primer-binding regions
`nextflowLogs`|File|All nextflow workflow task stdout and stderr logs gzipped and named by task.


## Niassa + Cromwell

This WDL workflow is wrapped in a Niassa workflow (https://github.com/oicr-gsi/pipedev/tree/master/pipedev-niassa-cromwell-workflow) so that it can used with the Niassa metadata tracking system (https://github.com/oicr-gsi/niassa).

* Building
```
mvn clean install
```

* Testing
```
mvn clean verify \
-Djava_opts="-Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication" \
-DrunTestThreads=2 \
-DskipITs=false \
-DskipRunITs=false \
-DworkingDirectory=/path/to/tmp/ \
-DschedulingHost=niassa_oozie_host \
-DwebserviceUrl=http://niassa-url:8080 \
-DwebserviceUser=niassa_user \
-DwebservicePassword=niassa_user_password \
-Dcromwell-host=http://cromwell-url:8000
```

## Support

For support, please file an issue on the [Github project](https://github.com/oicr-gsi) or send an email to gsi@oicr.on.ca .

_Generated with generate-markdown-readme (https://github.com/oicr-gsi/gsi-wdl-tools/)_
