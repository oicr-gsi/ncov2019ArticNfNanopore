version 1.0
workflow ncov2019ArticNfNanopore {
    input {
        String? profile
        String method
        String prefix
        String basecalledFastq
        String fast5Path
        File sequencingSummary
    }

    parameter_meta {
        profile: "Optional. May be conda,singularity,docker,slurm,lsf."
        method: "Either nanopolish or medaka."
        prefix: "String prepended to output files."
        basecalledFastq: "A directory containing basecalled fastqs. This is the output directory from guppy_barcoder or guppy_basecaller - usually fastq_pass. This can optionally contain barcodeXX directories, which are auto-detected."
        fast5Path: "Directory containing the fast5 files."
        sequencingSummary: "The path to the sequencing_summary.txt produced by guppy."
    }

    meta {
        author: "Savo Lazic"
        email: "savo.lazic@oicr.on.ca"
        description: "This Nextflow pipeline automates the ARTIC network nCoV-2019 novel coronavirus bioinformatics protocol. It will turn SARS-COV2 sequencing data (Illumina or Nanopore) into consensus sequences and provide other helpful outputs to assist the project's sequencing centres with submitting data. Pipeline documentation at https://artic.readthedocs.io/en/latest/minion/."
        dependencies:
        [
            {
                name: "ncov2019-artic-nf-nanopore/20200926",
                url: "https://github.com/connor-lab/ncov2019-artic-nf"
            },
            {
                name: "artic-ncov2019-primer-schemes/20200908",
                url: "https://github.com/artic-network/primer-schemes"
            }
        ]
        output_meta: {
            bamRaw: "The raw alignment of sample reads to reference genome",
            bamRawIndex: "The BAM index for the raw alignments BAM",
            bamPrimerTrimmed: "BAM file for visualisation after primer-binding site trimming",
            bamPrimerTrimmedIndex: "BAM index file for visualisation after primer-binding site trimming",
            bamTrimmed: "BAM file with the primers left on (used in variant calling)",
            bamTrimmedIndex: "BAM index file with the primers left on (used in variant calling)",
            fastaConcensus: "Consensus sequence",
            fastaMuscle: "An alignment of the consensus sequence against the reference sequence",
            qcCsv: "QC summary",
            vcfFail: "Detected variants in VCF format failing quality filter",
            vcfMerged: "All detected variants in VCF format",
            vcfPass: "Detected variants in VCF format passing quality filter (gz compressed)",
            vcfPrimers: "Detected variants falling in primer-binding regions",
            nextflowLogs: "All nextflow workflow task stdout and stderr logs gzipped and named by task."
        }
    }

    call runNcov2019ArticNfNanopore {
        input:
            profile = profile,
            method = method,
            prefix = prefix,
            basecalledFastq = basecalledFastq,
            fast5Path = fast5Path,
            sequencingSummary = sequencingSummary
    }

    output {
        File bamRaw = runNcov2019ArticNfNanopore.bamRaw
        File bamRawIndex = runNcov2019ArticNfNanopore.bamRawIndex
        File bamPrimerTrimmed = runNcov2019ArticNfNanopore.bamPrimerTrimmed
        File bamPrimerTrimmedIndex = runNcov2019ArticNfNanopore.bamPrimerTrimmedIndex
        File bamTrimmed = runNcov2019ArticNfNanopore.bamTrimmed
        File bamTrimmedIndex = runNcov2019ArticNfNanopore.bamTrimmedIndex
        File fastaConcensus = runNcov2019ArticNfNanopore.fastaConcensus
        File fastaMuscle = runNcov2019ArticNfNanopore.fastaMuscle
        File qcCsv = runNcov2019ArticNfNanopore.qcCsv
        File vcfFail = runNcov2019ArticNfNanopore.vcfFail
        File vcfMerged = runNcov2019ArticNfNanopore.vcfMerged
        File vcfPass = runNcov2019ArticNfNanopore.vcfPass
        File vcfPrimers = runNcov2019ArticNfNanopore.vcfPrimers
        File nextflowLogs = runNcov2019ArticNfNanopore.nextflowLogs
    }
}

task runNcov2019ArticNfNanopore {
    input {
        String? profile
        String method
        String prefix
        String basecalledFastq
        String fast5Path
        File sequencingSummary
        String modules = "ncov2019-artic-nf-nanopore/20200926 artic-ncov2019-primer-schemes/20200908"
        String ncov2019ArticNextflowPath = "$NCOV2019_ARTIC_NF_NANOPORE_ROOT"
        String schemeRepoURL = "$ARTIC_NCOV2019_PRIMER_SCHEMES_ROOT"
        String? schemeDir
        String? schemeName
        String? schemeVersion
        String? additionalParameters
        Int threads = 4
        Int jobMemory = 8
        Int timeout = 4
    }
    String fileName = prefix + '_' + basename(basecalledFastq)
    String profileFlag = if defined(profile) then "-profile ~{profile}" else ""
    String schemeDirFlag = if defined(schemeDir) then "--schemeDir ~{schemeDir}" else ""
    String schemeNameFlag = if defined(schemeName) then "--scheme ~{schemeName}" else ""
    String schemeVersionFlag = if defined(schemeVersion) then "--schemeVersion ~{schemeVersion}" else ""

    parameter_meta {
        profile: "Optional. May be conda,singularity,docker,slurm,lsf."
        method: "Either nanopolish or medaka."
        prefix: "String prepended to output files."
        basecalledFastq: "A directory containing basecalled fastqs. This is the output directory from guppy_barcoder or guppy_basecaller - usually fastq_pass. This can optionally contain barcodeXX directories, which are auto-detected."
        fast5Path: "Directory containing the fast5 files."
        sequencingSummary: "The path to the sequencing_summary.txt produced by guppy."
        modules: "Modules to load in modulator."
        ncov2019ArticNextflowPath: "Path to Nextflow workflow loaded by ncov2019-artic-nf-nanopore module. To download the most current remote repo use connor-lab/ncov2019-artic-nf"
        schemeRepoURL: "Repo to download your primer scheme from. Loaded locally using environemntal variable set by artic-ncov2019-primer-schemes module."
        schemeDir: "Directory within schemeRepoURL that contains primer schemes. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config"
        schemeName: "Directory within schemeDir that contains ncov2019 primer schema. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config"
        schemeVersion: "Version of primer schema to use. See workflow default https://github.com/connor-lab/ncov2019-artic-nf/blob/af2e515adff2bbd1149af20673c64b7ebd34eb1c/conf/base.config"
        additionalParameters: "Any additional parameters that need to be passed to the Nextflow workflow"
        jobMemory: "Memory (GB) allocated for this job."
        threads: "Requested CPU threads."
        timeout: "Number of hours before task timeout."
    }

    command <<<
        set -euo pipefail
        nextflow run ~{ncov2019ArticNextflowPath} ~{profileFlag} \
            --schemeRepoURL ~{schemeRepoURL} \
            --~{method} \
            --prefix ~{prefix} \
            --basecalled_fastq ~{basecalledFastq} \
            --fast5_pass ~{fast5Path} \
            --sequencing_summary ~{sequencingSummary} \
            ~{schemeDirFlag} ~{schemeNameFlag} ~{schemeVersionFlag} \
            ~{additionalParameters}

        # Folder names change depending on the method arguement.
        # Move all files into the results folder
        mv results/articNcovNanopore*/* results

        # Small vcf files are sometimes zipped and sometimes not. Unzip all.
        gunzip -dk results/*.vcf.gz

        # extract all logs from the nextflow working directory
        # Copied from https://github.com/oicr-gsi/ncov2019ArticNf
        NEXTFLOW_ID="$(nextflow log -q | head -1)"
        NEXTFLOW_TASKS=$(nextflow log "${NEXTFLOW_ID}" -f "name,workdir" -s '\t')
        mkdir -p logs
        while IFS=$'\t' read -r name workdir; do
          FILENAME="$(echo "${name}" | sed -e 's/[^A-Za-z0-9._-]/_/g')"
          if [ -f "$workdir/.command.log" ]; then
            cp "$workdir/.command.log" "logs/$FILENAME.stdout"
          fi
          if [ -f "$workdir/.command.err" ]; then
            cp "$workdir/.command.err" "logs/$FILENAME.stderr"
          fi
        done <<< ${NEXTFLOW_TASKS}
        tar -zcvf ~{prefix}.logs.tar.gz logs/
    >>>

    output {
        File bamRaw = "results/~{fileName}.sorted.bam"
        File bamRawIndex = "results/~{fileName}.sorted.bam.bai"
        File bamPrimerTrimmed = "results/~{fileName}.primertrimmed.rg.sorted.bam"
        File bamPrimerTrimmedIndex = "results/~{fileName}.primertrimmed.rg.sorted.bam.bai"
        File bamTrimmed = "results/~{fileName}.trimmed.rg.sorted.bam"
        File bamTrimmedIndex = "results/~{fileName}.trimmed.rg.sorted.bam.bai"
        File fastaConcensus = "results/~{fileName}.consensus.fasta"
        File fastaMuscle = "results/~{fileName}.muscle.out.fasta"
        File qcCsv = "results/~{prefix}.qc.csv"
        File vcfFail = "results/~{fileName}.fail.vcf"
        File vcfMerged = "results/~{fileName}.merged.vcf"
        File vcfPass = "results/~{fileName}.pass.vcf"
        File vcfPrimers = "results/~{fileName}.primers.vcf"
        File nextflowLogs = "~{prefix}.logs.tar.gz"
    }

    meta {
        output_meta: {
            bamRaw: "The raw alignment of sample reads to reference genome",
            bamRawIndex: "The BAM index for the raw alignments BAM",
            bamPrimerTrimmed: "BAM file for visualisation after primer-binding site trimming",
            bamPrimerTrimmedIndex: "BAM index file for visualisation after primer-binding site trimming",
            bamTrimmed: "BAM file with the primers left on (used in variant calling)",
            bamTrimmedIndex: "BAM index file with the primers left on (used in variant calling)",
            fastaConcensus: "Consensus sequence",
            fastaMuscle: "An alignment of the consensus sequence against the reference sequence",
            qcCsv: "QC summary",
            vcfFail: "Detected variants in VCF format failing quality filter",
            vcfMerged: "All detected variants in VCF format",
            vcfPass: "Detected variants in VCF format passing quality filter (gz compressed)",
            vcfPrimers: "Detected variants falling in primer-binding regions",
            nextflowLogs: "All nextflow workflow task stdout and stderr logs gzipped and named by task."
        }
    }

    runtime {
        modules: "~{modules}"
        memory:  "~{jobMemory} GB"
        cpu:     "~{threads}"
        timeout: "~{timeout}"
    }
}
