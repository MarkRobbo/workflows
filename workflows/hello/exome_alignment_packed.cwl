{
    "cwlVersion": "v1.0", 
    "$graph": [
        {
            "class": "CommandLineTool", 
            "label": "samtools view cram to bam", 
            "baseCommand": [
                "/opt/samtools/bin/samtools", 
                "view", 
                "-b"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 4000
                }
            ], 
            "arguments": [
                "-o", 
                {
                    "valueFrom": "$(runtime.outdir)/output.bam"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#cram_to_bam.cwl/cram"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "-T", 
                        "position": 1
                    }, 
                    "id": "#cram_to_bam.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "output.bam"
                    }, 
                    "id": "#cram_to_bam.cwl/bam"
                }
            ], 
            "id": "#cram_to_bam.cwl"
        }, 
        {
            "class": "Workflow", 
            "label": "cram_to_bam workflow", 
            "inputs": [
                {
                    "type": "File", 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#workflow.cwl/cram"
                }, 
                {
                    "type": "string", 
                    "id": "#workflow.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#workflow.cwl/index_bam/indexed_bam", 
                    "secondaryFiles": [
                        ".bai"
                    ], 
                    "id": "#workflow.cwl/bam"
                }
            ], 
            "steps": [
                {
                    "run": "#cram_to_bam.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl/cram", 
                            "id": "#workflow.cwl/cram_to_bam/cram"
                        }, 
                        {
                            "source": "#workflow.cwl/reference", 
                            "id": "#workflow.cwl/cram_to_bam/reference"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl/cram_to_bam/bam"
                    ], 
                    "id": "#workflow.cwl/cram_to_bam"
                }, 
                {
                    "run": "#index_bam.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl/cram_to_bam/bam", 
                            "id": "#workflow.cwl/index_bam/bam"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl/index_bam/indexed_bam"
                    ], 
                    "id": "#workflow.cwl/index_bam"
                }
            ], 
            "id": "#workflow.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "samtools index", 
            "arguments": [
                "cp", 
                "$(inputs.bam.path)", 
                "$(runtime.outdir)/$(inputs.bam.basename)", 
                {
                    "valueFrom": " && ", 
                    "shellQuote": false
                }, 
                "/opt/samtools/bin/samtools", 
                "index", 
                "$(inputs.bam.path)", 
                "$(runtime.outdir)/$(inputs.bam.basename).bai"
            ], 
            "requirements": [
                {
                    "class": "ShellCommandRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#index_bam.cwl/bam"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".bai"
                    ], 
                    "outputBinding": {
                        "glob": "$(inputs.bam.basename)"
                    }, 
                    "id": "#index_bam.cwl/indexed_bam"
                }
            ], 
            "id": "#index_bam.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "SelectVariants (GATK 3.6)", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx4g", 
                "-jar", 
                "/opt/GenomeAnalysisTK.jar", 
                "-T", 
                "SelectVariants"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 6000, 
                    "tmpdirMin": 25000
                }
            ], 
            "arguments": [
                "-o", 
                {
                    "valueFrom": "$(runtime.outdir)/$(inputs.output_vcf_basename).vcf.gz"
                }
            ], 
            "inputs": [
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "--excludeFiltered", 
                        "position": 4
                    }, 
                    "id": "#select_variants.cwl/exclude_filtered"
                }, 
                {
                    "type": [
                        "null", 
                        "File"
                    ], 
                    "inputBinding": {
                        "prefix": "-L", 
                        "position": 3
                    }, 
                    "id": "#select_variants.cwl/interval_list"
                }, 
                {
                    "type": [
                        "null", 
                        "string"
                    ], 
                    "default": "select_variants", 
                    "id": "#select_variants.cwl/output_vcf_basename"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "-R", 
                        "position": 1
                    }, 
                    "id": "#select_variants.cwl/reference"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "--variant", 
                        "position": 2
                    }, 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#select_variants.cwl/vcf"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "outputBinding": {
                        "glob": "$(inputs.output_vcf_basename).vcf.gz"
                    }, 
                    "id": "#select_variants.cwl/filtered_vcf"
                }
            ], 
            "id": "#select_variants.cwl"
        }, 
        {
            "class": "Workflow", 
            "label": "exome alignment with qc", 
            "requirements": [
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#main/bait_intervals"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#main/bams"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#main/dbsnp"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#main/known_indels"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#main/mills"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#main/omni_vcf"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "string"
                    }, 
                    "id": "#main/readgroups"
                }, 
                {
                    "type": "string", 
                    "id": "#main/reference"
                }, 
                {
                    "type": "File", 
                    "id": "#main/target_intervals"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#main/qc/alignment_summary_metrics", 
                    "id": "#main/alignment_summary_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/alignment/final_cram", 
                    "id": "#main/cram"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/flagstats", 
                    "id": "#main/flagstats"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/hs_metrics", 
                    "id": "#main/hs_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/insert_size_metrics", 
                    "id": "#main/insert_size_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/per_target_coverage_metrics", 
                    "id": "#main/per_target_coverage_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/verify_bam_id_depth", 
                    "id": "#main/verify_bam_id_depth"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#main/qc/verify_bam_id_metrics", 
                    "id": "#main/verify_bam_id_metrics"
                }
            ], 
            "steps": [
                {
                    "run": "#workflow.cwl_2", 
                    "in": [
                        {
                            "source": "#main/bams", 
                            "id": "#main/alignment/bams"
                        }, 
                        {
                            "source": "#main/dbsnp", 
                            "id": "#main/alignment/dbsnp"
                        }, 
                        {
                            "source": "#main/known_indels", 
                            "id": "#main/alignment/known_indels"
                        }, 
                        {
                            "source": "#main/mills", 
                            "id": "#main/alignment/mills"
                        }, 
                        {
                            "source": "#main/readgroups", 
                            "id": "#main/alignment/readgroups"
                        }, 
                        {
                            "source": "#main/reference", 
                            "id": "#main/alignment/reference"
                        }
                    ], 
                    "out": [
                        "#main/alignment/final_cram"
                    ], 
                    "id": "#main/alignment"
                }, 
                {
                    "run": "#workflow_exome.cwl", 
                    "in": [
                        {
                            "source": "#main/bait_intervals", 
                            "id": "#main/qc/bait_intervals"
                        }, 
                        {
                            "source": "#main/alignment/final_cram", 
                            "id": "#main/qc/cram"
                        }, 
                        {
                            "source": "#main/omni_vcf", 
                            "id": "#main/qc/omni_vcf"
                        }, 
                        {
                            "source": "#main/reference", 
                            "id": "#main/qc/reference"
                        }, 
                        {
                            "source": "#main/target_intervals", 
                            "id": "#main/qc/target_intervals"
                        }
                    ], 
                    "out": [
                        "#main/qc/insert_size_metrics", 
                        "#main/qc/alignment_summary_metrics", 
                        "#main/qc/hs_metrics", 
                        "#main/qc/per_target_coverage_metrics", 
                        "#main/qc/flagstats", 
                        "#main/qc/verify_bam_id_metrics", 
                        "#main/qc/verify_bam_id_depth"
                    ], 
                    "id": "#main/qc"
                }
            ], 
            "id": "#main"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "collect alignment summary metrics", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/usr/picard/picard.jar", 
                "CollectAlignmentSummaryMetrics"
            ], 
            "arguments": [
                "OUTPUT=", 
                {
                    "valueFrom": "$(runtime.outdir)/AlignmentSummaryMetrics.txt"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "INPUT="
                    }, 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#collect_alignment_summary_metrics.cwl/cram"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "REFERENCE_SEQUENCE="
                    }, 
                    "id": "#collect_alignment_summary_metrics.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "AlignmentSummaryMetrics.txt"
                    }, 
                    "id": "#collect_alignment_summary_metrics.cwl/alignment_summary_metrics"
                }
            ], 
            "id": "#collect_alignment_summary_metrics.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "collect HS metrics", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/usr/picard/picard.jar", 
                "CollectHsMetrics"
            ], 
            "arguments": [
                "O=", 
                {
                    "valueFrom": "$(runtime.outdir)/HsMetrics.txt"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "BAIT_INTERVALS="
                    }, 
                    "id": "#collect_hs_metrics.cwl/bait_intervals"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "I="
                    }, 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#collect_hs_metrics.cwl/cram"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "inputBinding": {
                        "prefix": "PER_TARGET_COVERAGE=PerTargetCoverage.txt"
                    }, 
                    "id": "#collect_hs_metrics.cwl/per_target_coverage"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "R="
                    }, 
                    "id": "#collect_hs_metrics.cwl/reference"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "TARGET_INTERVALS="
                    }, 
                    "id": "#collect_hs_metrics.cwl/target_intervals"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "HsMetrics.txt"
                    }, 
                    "id": "#collect_hs_metrics.cwl/hs_metrics"
                }, 
                {
                    "type": [
                        "null", 
                        "File"
                    ], 
                    "outputBinding": {
                        "glob": "PerTargetCoverage.txt"
                    }, 
                    "id": "#collect_hs_metrics.cwl/per_target_coverage_metrics"
                }
            ], 
            "id": "#collect_hs_metrics.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "collect insert size metrics", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/usr/picard/picard.jar", 
                "CollectInsertSizeMetrics"
            ], 
            "arguments": [
                "O=", 
                {
                    "valueFrom": "$(runtime.outdir)/InsertSizeMetrics.txt"
                }, 
                "H=", 
                {
                    "valueFrom": "$(runtime.outdir)/InsertSizeHistogram.pdf"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "I="
                    }, 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#collect_insert_size_metrics.cwl/cram"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "InsertSizeMetrics.txt"
                    }, 
                    "id": "#collect_insert_size_metrics.cwl/insert_size_metrics"
                }
            ], 
            "id": "#collect_insert_size_metrics.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "samtools flagstat", 
            "baseCommand": [
                "/opt/samtools/bin/samtools", 
                "flagstat"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 4000
                }
            ], 
            "stdout": "flagstat.out", 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#samtools_flagstat.cwl/cram"
                }
            ], 
            "outputs": [
                {
                    "type": "stdout", 
                    "id": "#samtools_flagstat.cwl/flagstats"
                }
            ], 
            "id": "#samtools_flagstat.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "verify BAM ID", 
            "baseCommand": "/usr/local/bin/verifyBamID", 
            "arguments": [
                "--out", 
                {
                    "valueFrom": "$(runtime.outdir)/VerifyBamId"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 4000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "--bam"
                    }, 
                    "id": "#verify_bam_id.cwl/bam"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "--vcf"
                    }, 
                    "id": "#verify_bam_id.cwl/vcf"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "VerifyBamId.depthSM"
                    }, 
                    "id": "#verify_bam_id.cwl/verify_bam_id_depth"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "VerifyBamId.selfSM"
                    }, 
                    "id": "#verify_bam_id.cwl/verify_bam_id_metrics"
                }
            ], 
            "id": "#verify_bam_id.cwl"
        }, 
        {
            "class": "Workflow", 
            "label": "Exome QC workflow", 
            "requirements": [
                {
                    "class": "SubworkflowFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#workflow_exome.cwl/bait_intervals"
                }, 
                {
                    "type": [
                        "null", 
                        "boolean"
                    ], 
                    "id": "#workflow_exome.cwl/collect_hs_metrics_per_target_coverage"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        "^.crai"
                    ], 
                    "id": "#workflow_exome.cwl/cram"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#workflow_exome.cwl/omni_vcf"
                }, 
                {
                    "type": "string", 
                    "id": "#workflow_exome.cwl/reference"
                }, 
                {
                    "type": "File", 
                    "id": "#workflow_exome.cwl/target_intervals"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/collect_alignment_summary_metrics/alignment_summary_metrics", 
                    "id": "#workflow_exome.cwl/alignment_summary_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/samtools_flagstat/flagstats", 
                    "id": "#workflow_exome.cwl/flagstats"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/collect_hs_metrics/hs_metrics", 
                    "id": "#workflow_exome.cwl/hs_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/collect_insert_size_metrics/insert_size_metrics", 
                    "id": "#workflow_exome.cwl/insert_size_metrics"
                }, 
                {
                    "type": [
                        "null", 
                        "File"
                    ], 
                    "outputSource": "#workflow_exome.cwl/collect_hs_metrics/per_target_coverage_metrics", 
                    "id": "#workflow_exome.cwl/per_target_coverage_metrics"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/verify_bam_id/verify_bam_id_depth", 
                    "id": "#workflow_exome.cwl/verify_bam_id_depth"
                }, 
                {
                    "type": "File", 
                    "outputSource": "#workflow_exome.cwl/verify_bam_id/verify_bam_id_metrics", 
                    "id": "#workflow_exome.cwl/verify_bam_id_metrics"
                }
            ], 
            "steps": [
                {
                    "run": "#collect_alignment_summary_metrics.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/cram", 
                            "id": "#workflow_exome.cwl/collect_alignment_summary_metrics/cram"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/reference", 
                            "id": "#workflow_exome.cwl/collect_alignment_summary_metrics/reference"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/collect_alignment_summary_metrics/alignment_summary_metrics"
                    ], 
                    "id": "#workflow_exome.cwl/collect_alignment_summary_metrics"
                }, 
                {
                    "run": "#collect_hs_metrics.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/bait_intervals", 
                            "id": "#workflow_exome.cwl/collect_hs_metrics/bait_intervals"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/cram", 
                            "id": "#workflow_exome.cwl/collect_hs_metrics/cram"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/collect_hs_metrics_per_target_coverage", 
                            "id": "#workflow_exome.cwl/collect_hs_metrics/per_target_coverage"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/reference", 
                            "id": "#workflow_exome.cwl/collect_hs_metrics/reference"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/target_intervals", 
                            "id": "#workflow_exome.cwl/collect_hs_metrics/target_intervals"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/collect_hs_metrics/hs_metrics", 
                        "#workflow_exome.cwl/collect_hs_metrics/per_target_coverage_metrics"
                    ], 
                    "id": "#workflow_exome.cwl/collect_hs_metrics"
                }, 
                {
                    "run": "#collect_insert_size_metrics.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/cram", 
                            "id": "#workflow_exome.cwl/collect_insert_size_metrics/cram"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/collect_insert_size_metrics/insert_size_metrics"
                    ], 
                    "id": "#workflow_exome.cwl/collect_insert_size_metrics"
                }, 
                {
                    "run": "#workflow.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/cram", 
                            "id": "#workflow_exome.cwl/cram_to_bam/cram"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/reference", 
                            "id": "#workflow_exome.cwl/cram_to_bam/reference"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/cram_to_bam/bam"
                    ], 
                    "id": "#workflow_exome.cwl/cram_to_bam"
                }, 
                {
                    "run": "#samtools_flagstat.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/cram", 
                            "id": "#workflow_exome.cwl/samtools_flagstat/cram"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/samtools_flagstat/flagstats"
                    ], 
                    "id": "#workflow_exome.cwl/samtools_flagstat"
                }, 
                {
                    "run": "#select_variants.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/target_intervals", 
                            "id": "#workflow_exome.cwl/select_variants/interval_list"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/reference", 
                            "id": "#workflow_exome.cwl/select_variants/reference"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/omni_vcf", 
                            "id": "#workflow_exome.cwl/select_variants/vcf"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/select_variants/filtered_vcf"
                    ], 
                    "id": "#workflow_exome.cwl/select_variants"
                }, 
                {
                    "run": "#verify_bam_id.cwl", 
                    "in": [
                        {
                            "source": "#workflow_exome.cwl/cram_to_bam/bam", 
                            "id": "#workflow_exome.cwl/verify_bam_id/bam"
                        }, 
                        {
                            "source": "#workflow_exome.cwl/select_variants/filtered_vcf", 
                            "id": "#workflow_exome.cwl/verify_bam_id/vcf"
                        }
                    ], 
                    "out": [
                        "#workflow_exome.cwl/verify_bam_id/verify_bam_id_metrics", 
                        "#workflow_exome.cwl/verify_bam_id/verify_bam_id_depth"
                    ], 
                    "id": "#workflow_exome.cwl/verify_bam_id"
                }
            ], 
            "id": "#workflow_exome.cwl"
        }, 
        {
            "class": "Workflow", 
            "label": "Unaligned to aligned BAM", 
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }, 
                {
                    "class": "SubworkflowFeatureRequirement"
                }, 
                {
                    "class": "MultipleInputFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#align.cwl/bam"
                }, 
                {
                    "type": "string", 
                    "id": "#align.cwl/readgroup"
                }, 
                {
                    "type": "string", 
                    "id": "#align.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#align.cwl/align_and_tag/aligned_bam", 
                    "id": "#align.cwl/tagged_bam"
                }
            ], 
            "steps": [
                {
                    "run": "#align_and_tag.cwl", 
                    "in": [
                        {
                            "source": "#align.cwl/revert_to_fastq/fastq", 
                            "id": "#align.cwl/align_and_tag/fastq"
                        }, 
                        {
                            "source": "#align.cwl/revert_to_fastq/second_end_fastq", 
                            "id": "#align.cwl/align_and_tag/fastq2"
                        }, 
                        {
                            "source": "#align.cwl/readgroup", 
                            "id": "#align.cwl/align_and_tag/readgroup"
                        }, 
                        {
                            "source": "#align.cwl/reference", 
                            "id": "#align.cwl/align_and_tag/reference"
                        }
                    ], 
                    "out": [
                        "#align.cwl/align_and_tag/aligned_bam"
                    ], 
                    "id": "#align.cwl/align_and_tag"
                }, 
                {
                    "run": "#revert_to_fastq.cwl", 
                    "in": [
                        {
                            "source": "#align.cwl/bam", 
                            "id": "#align.cwl/revert_to_fastq/bam"
                        }
                    ], 
                    "out": [
                        "#align.cwl/revert_to_fastq/fastq", 
                        "#align.cwl/revert_to_fastq/second_end_fastq"
                    ], 
                    "id": "#align.cwl/revert_to_fastq"
                }
            ], 
            "id": "#align.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "align with bwa_mem and tag", 
            "baseCommand": [
                "/bin/bash", 
                "/usr/bin/alignment_helper.sh"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "coresMin": 8, 
                    "ramMin": 16000
                }
            ], 
            "stdout": "refAlign.bam", 
            "arguments": [
                {
                    "position": 5, 
                    "valueFrom": "$(runtime.cores)"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 3
                    }, 
                    "id": "#align_and_tag.cwl/fastq"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 4
                    }, 
                    "id": "#align_and_tag.cwl/fastq2"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#align_and_tag.cwl/readgroup"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "id": "#align_and_tag.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "stdout", 
                    "id": "#align_and_tag.cwl/aligned_bam"
                }
            ], 
            "id": "#align_and_tag.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "apply BQSR", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/opt/GenomeAnalysisTK.jar", 
                "-T", 
                "PrintReads"
            ], 
            "arguments": [
                "-o", 
                {
                    "valueFrom": "$(runtime.outdir)/Final.bam"
                }, 
                "-preserveQ", 
                "6", 
                "-SQQ", 
                "10", 
                "-SQQ", 
                "20", 
                "-SQQ", 
                "30", 
                "-nct", 
                "8", 
                "--disable_indel_quals"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-I", 
                        "position": 2
                    }, 
                    "secondaryFiles": [
                        ".bai"
                    ], 
                    "id": "#apply_bqsr.cwl/bam"
                }, 
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-BQSR", 
                        "position": 3
                    }, 
                    "id": "#apply_bqsr.cwl/bqsr_table"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "-R", 
                        "position": 1
                    }, 
                    "id": "#apply_bqsr.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "Final.bam"
                    }, 
                    "secondaryFiles": [
                        "^.bai"
                    ], 
                    "id": "#apply_bqsr.cwl/bqsr_bam"
                }
            ], 
            "id": "#apply_bqsr.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "BAM to CRAM conversion", 
            "baseCommand": [
                "/opt/samtools/bin/samtools", 
                "view", 
                "-C"
            ], 
            "stdout": "final.cram", 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 2
                    }, 
                    "id": "#bam_to_cram.cwl/bam"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "-T", 
                        "position": 1
                    }, 
                    "id": "#bam_to_cram.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "stdout", 
                    "id": "#bam_to_cram.cwl/cram"
                }
            ], 
            "id": "#bam_to_cram.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "create BQSR table", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/opt/GenomeAnalysisTK.jar", 
                "-T", 
                "BaseRecalibrator"
            ], 
            "arguments": [
                "-o", 
                {
                    "valueFrom": "$(runtime.outdir)/bqsr.table"
                }, 
                "--preserve_qscores_less_than", 
                "6", 
                "--disable_auto_index_creation_and_locking_when_reading_rods", 
                "--disable_bam_indexing", 
                "-dfrac", 
                ".1", 
                "-L", 
                "chr1", 
                "-L", 
                "chr2", 
                "-L", 
                "chr3", 
                "-L", 
                "chr4", 
                "-L", 
                "chr5", 
                "-L", 
                "chr6", 
                "-L", 
                "chr7", 
                "-L", 
                "chr8", 
                "-L", 
                "chr9", 
                "-L", 
                "chr10", 
                "-L", 
                "chr11", 
                "-L", 
                "chr12", 
                "-L", 
                "chr13", 
                "-L", 
                "chr14", 
                "-L", 
                "chr15", 
                "-L", 
                "chr16", 
                "-L", 
                "chr17", 
                "-L", 
                "chr18", 
                "-L", 
                "chr19", 
                "-L", 
                "chr20", 
                "-L", 
                "chr21", 
                "-L", 
                "chr22", 
                "-nct", 
                "4"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "-I", 
                        "position": 2
                    }, 
                    "secondaryFiles": [
                        ".bai"
                    ], 
                    "id": "#bqsr.cwl/bam"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "File", 
                        "inputBinding": {
                            "prefix": "-knownSites", 
                            "position": 3
                        }
                    }, 
                    "id": "#bqsr.cwl/known_sites"
                }, 
                {
                    "type": "string", 
                    "inputBinding": {
                        "prefix": "-R", 
                        "position": 1
                    }, 
                    "id": "#bqsr.cwl/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "bqsr.table"
                    }, 
                    "id": "#bqsr.cwl/bqsr_table"
                }
            ], 
            "id": "#bqsr.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "samtools index cram", 
            "arguments": [
                "cp", 
                "$(inputs.cram.path)", 
                "$(runtime.outdir)/$(inputs.cram.basename)", 
                {
                    "valueFrom": " && ", 
                    "shellQuote": false
                }, 
                "/opt/samtools/bin/samtools", 
                "index", 
                "$(runtime.outdir)/$(inputs.cram.basename)", 
                "$(runtime.outdir)/$(inputs.cram.basename).crai", 
                {
                    "valueFrom": " && ", 
                    "shellQuote": false
                }, 
                "ln", 
                "-s", 
                "$(inputs.cram.basename).crai", 
                "$(runtime.outdir)/$(inputs.cram.nameroot).crai"
            ], 
            "requirements": [
                {
                    "class": "ShellCommandRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "id": "#index_cram.cwl/cram"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".crai", 
                        "^.crai"
                    ], 
                    "outputBinding": {
                        "glob": "$(inputs.cram.basename)"
                    }, 
                    "id": "#index_cram.cwl/indexed_cram"
                }
            ], 
            "id": "#index_cram.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "mark duplicates and sort", 
            "baseCommand": [
                "/bin/bash", 
                "/usr/bin/markduplicates_helper.sh"
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "coresMin": 8, 
                    "ramMin": 40000
                }
            ], 
            "arguments": [
                {
                    "position": 2, 
                    "valueFrom": "$(runtime.cores)"
                }, 
                {
                    "position": 3, 
                    "valueFrom": "$(runtime.outdir)/MarkedSorted.bam"
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#mark_duplicates_and_sort.cwl/bam"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "MarkedSorted.bam"
                    }, 
                    "secondaryFiles": [
                        ".bai"
                    ], 
                    "id": "#mark_duplicates_and_sort.cwl/sorted_bam"
                }
            ], 
            "id": "#mark_duplicates_and_sort.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "merge BAMs", 
            "baseCommand": [
                "/opt/samtools/bin/samtools", 
                "merge"
            ], 
            "arguments": [
                "AlignedMerged.bam"
            ], 
            "inputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#merge.cwl/bams"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "AlignedMerged.bam"
                    }, 
                    "id": "#merge.cwl/merged_bam"
                }
            ], 
            "id": "#merge.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "sort BAM by name", 
            "baseCommand": [
                "/usr/bin/sambamba", 
                "sort"
            ], 
            "arguments": [
                "-t", 
                {
                    "valueFrom": "$(runtime.cores)"
                }, 
                "-m", 
                "12G", 
                "-n", 
                "-o", 
                {
                    "valueFrom": "$(runtime.outdir)/NameSorted.bam"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 12000, 
                    "coresMin": 8
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "position": 1
                    }, 
                    "id": "#name_sort.cwl/bam"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "NameSorted.bam"
                    }, 
                    "id": "#name_sort.cwl/name_sorted_bam"
                }
            ], 
            "id": "#name_sort.cwl"
        }, 
        {
            "class": "CommandLineTool", 
            "label": "revert to fastq", 
            "baseCommand": [
                "/usr/bin/java", 
                "-Xmx16g", 
                "-jar", 
                "/opt/picard/picard.jar", 
                "SamToFastq"
            ], 
            "arguments": [
                "FASTQ=", 
                {
                    "valueFrom": "$(runtime.outdir)/revert_to_fastq.rFastq1"
                }, 
                "SECOND_END_FASTQ=", 
                {
                    "valueFrom": "$(runtime.outdir)/revert_to_fastq.rFastq2"
                }
            ], 
            "requirements": [
                {
                    "class": "ResourceRequirement", 
                    "ramMin": 16000, 
                    "tmpdirMin": 25000
                }
            ], 
            "inputs": [
                {
                    "type": "File", 
                    "inputBinding": {
                        "prefix": "I=", 
                        "position": 1
                    }, 
                    "id": "#revert_to_fastq.cwl/bam"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "revert_to_fastq.rFastq1"
                    }, 
                    "id": "#revert_to_fastq.cwl/fastq"
                }, 
                {
                    "type": "File", 
                    "outputBinding": {
                        "glob": "revert_to_fastq.rFastq2"
                    }, 
                    "id": "#revert_to_fastq.cwl/second_end_fastq"
                }
            ], 
            "id": "#revert_to_fastq.cwl"
        }, 
        {
            "class": "Workflow", 
            "label": "Unaligned BAM to BQSR and VCF", 
            "requirements": [
                {
                    "class": "ScatterFeatureRequirement"
                }, 
                {
                    "class": "SubworkflowFeatureRequirement"
                }, 
                {
                    "class": "MultipleInputFeatureRequirement"
                }
            ], 
            "inputs": [
                {
                    "type": {
                        "type": "array", 
                        "items": "File"
                    }, 
                    "id": "#workflow.cwl_2/bams"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#workflow.cwl_2/dbsnp"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#workflow.cwl_2/known_indels"
                }, 
                {
                    "type": "File", 
                    "secondaryFiles": [
                        ".tbi"
                    ], 
                    "id": "#workflow.cwl_2/mills"
                }, 
                {
                    "type": {
                        "type": "array", 
                        "items": "string"
                    }, 
                    "id": "#workflow.cwl_2/readgroups"
                }, 
                {
                    "type": "string", 
                    "id": "#workflow.cwl_2/reference"
                }
            ], 
            "outputs": [
                {
                    "type": "File", 
                    "outputSource": "#workflow.cwl_2/index_cram/indexed_cram", 
                    "secondaryFiles": [
                        ".crai", 
                        "^.crai"
                    ], 
                    "id": "#workflow.cwl_2/final_cram"
                }
            ], 
            "steps": [
                {
                    "scatter": [
                        "#workflow.cwl_2/align/bam", 
                        "#workflow.cwl_2/align/readgroup"
                    ], 
                    "scatterMethod": "dotproduct", 
                    "run": "#align.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/bams", 
                            "id": "#workflow.cwl_2/align/bam"
                        }, 
                        {
                            "source": "#workflow.cwl_2/readgroups", 
                            "id": "#workflow.cwl_2/align/readgroup"
                        }, 
                        {
                            "source": "#workflow.cwl_2/reference", 
                            "id": "#workflow.cwl_2/align/reference"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/align/tagged_bam"
                    ], 
                    "id": "#workflow.cwl_2/align"
                }, 
                {
                    "run": "#apply_bqsr.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/mark_duplicates_and_sort/sorted_bam", 
                            "id": "#workflow.cwl_2/apply_bqsr/bam"
                        }, 
                        {
                            "source": "#workflow.cwl_2/bqsr/bqsr_table", 
                            "id": "#workflow.cwl_2/apply_bqsr/bqsr_table"
                        }, 
                        {
                            "source": "#workflow.cwl_2/reference", 
                            "id": "#workflow.cwl_2/apply_bqsr/reference"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/apply_bqsr/bqsr_bam"
                    ], 
                    "id": "#workflow.cwl_2/apply_bqsr"
                }, 
                {
                    "run": "#bam_to_cram.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/apply_bqsr/bqsr_bam", 
                            "id": "#workflow.cwl_2/bam_to_cram/bam"
                        }, 
                        {
                            "source": "#workflow.cwl_2/reference", 
                            "id": "#workflow.cwl_2/bam_to_cram/reference"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/bam_to_cram/cram"
                    ], 
                    "id": "#workflow.cwl_2/bam_to_cram"
                }, 
                {
                    "run": "#bqsr.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/mark_duplicates_and_sort/sorted_bam", 
                            "id": "#workflow.cwl_2/bqsr/bam"
                        }, 
                        {
                            "source": [
                                "#workflow.cwl_2/dbsnp", 
                                "#workflow.cwl_2/mills", 
                                "#workflow.cwl_2/known_indels"
                            ], 
                            "id": "#workflow.cwl_2/bqsr/known_sites"
                        }, 
                        {
                            "source": "#workflow.cwl_2/reference", 
                            "id": "#workflow.cwl_2/bqsr/reference"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/bqsr/bqsr_table"
                    ], 
                    "id": "#workflow.cwl_2/bqsr"
                }, 
                {
                    "run": "#index_cram.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/bam_to_cram/cram", 
                            "id": "#workflow.cwl_2/index_cram/cram"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/index_cram/indexed_cram"
                    ], 
                    "id": "#workflow.cwl_2/index_cram"
                }, 
                {
                    "run": "#mark_duplicates_and_sort.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/name_sort/name_sorted_bam", 
                            "id": "#workflow.cwl_2/mark_duplicates_and_sort/bam"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/mark_duplicates_and_sort/sorted_bam"
                    ], 
                    "id": "#workflow.cwl_2/mark_duplicates_and_sort"
                }, 
                {
                    "run": "#merge.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/align/tagged_bam", 
                            "id": "#workflow.cwl_2/merge/bams"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/merge/merged_bam"
                    ], 
                    "id": "#workflow.cwl_2/merge"
                }, 
                {
                    "run": "#name_sort.cwl", 
                    "in": [
                        {
                            "source": "#workflow.cwl_2/merge/merged_bam", 
                            "id": "#workflow.cwl_2/name_sort/bam"
                        }
                    ], 
                    "out": [
                        "#workflow.cwl_2/name_sort/name_sorted_bam"
                    ], 
                    "id": "#workflow.cwl_2/name_sort"
                }
            ], 
            "id": "#workflow.cwl_2"
        }
    ]
}