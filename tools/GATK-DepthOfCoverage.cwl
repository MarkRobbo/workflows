#!/usr/bin/env cwl-runner

$namespaces:
  dct: http://purl.org/dc/terms/
  foaf: http://xmlns.com/foaf/0.1/
  doap: http://usefulinc.com/ns/doap#
  adms: http://www.w3.org/ns/adms#
  dcat: http://www.w3.org/ns/dcat#

$schemas:
- http://dublincore.org/2012/06/14/dcterms.rdf
- http://xmlns.com/foaf/spec/20140114.rdf
- http://usefulinc.com/ns/doap#
- http://www.w3.org/ns/adms#
- http://www.w3.org/ns/dcat.rdf

cwlVersion: v1.0
class: CommandLineTool

adms:includedAsset:
  doap:name: GATK
  doap:description: 'The Genome Analysis Toolkit or GATK is a software package for
    analysis of high-throughput sequencing data, developed by the Data Science and
    Data Engineering group at the Broad Institute. The toolkit offers a wide variety
    of tools, with a primary focus on variant discovery and genotyping as well as
    strong emphasis on data quality assurance. Its robust architecture, powerful processing
    engine and high-performance computing features make it capable of taking on projects
    of any size. http://broadinstitute.github.io/picard/command-line-overview.html#MergeSamFiles

    '
  doap:homepage: https://www.broadinstitute.org/gatk/
  doap:repository:
  - class: doap:GitRepository
    doap:location: https://github.com/broadgsa/gatk.git
  doap:release:
  - class: doap:Version
    doap:revision: '3.5'
  doap:license: mixed licensing model
  doap:category: commandline tool
  doap:programming-language: JAVA
  doap:developer:
  - class: foaf:Organization
    foaf:name: Broad Institute
doap:name: GATK-DepthOfCoverage.cwl
dcat:downloadURL: https://github.com/common-workflow-language/workflows/blob/master/tools/GATK-DepthOfCoverage.cwl

dct:creator:
- class: foaf:Organization
  foaf:name: UCSC
  foaf:member:
  - class: foaf:Person
    id: http://orcid.org/0000-0002-7681-6415
    foaf:name: Brian O'Connor
    foaf:mbox: mailto:briandoconnor@ucsc.edu

doap:maintainer:
- class: foaf:Organization
  foaf:name: UCSC
  foaf:member:
  - class: foaf:Person
    id: http://orcid.org/0000-0002-7681-6415
    foaf:name: Brian O'Connor
    foaf:mbox: mailto:briandoconnor@ucsc.edu

requirements:
- $import: envvar-global.yml
- $import: GATK-docker.yml

inputs: # position 0, for java args, 1 for the jar, 2 for the tool itself

  java_arg:
    type: string
    default: -Xmx4g
    inputBinding:
      position: 0

  GATKJar:
    type: File
    inputBinding:
      position: 1
      prefix: -jar
  threads:
    type: int
    default: 4
    inputBinding:
      prefix: -nt
      position: 2
    doc: number of threads

  omitIntervalStatistics:
    type: boolean?
    inputBinding:
      prefix: --omitIntervalStatistics
      position: 2
    doc: Do not calculate per-interval statistics

  omitDepthOutputAtEachBase:
    type: boolean?
    inputBinding:
      prefix: --omitDepthOutputAtEachBase
      position: 2
    doc: Do not output depth of coverage at each base

  reference:
    type: File
    format: http://edamontology.org/format_1929  # FASTA
    inputBinding:
      prefix: -R
      position: 2
    secondaryFiles:
    - .fai
    - ^.dict

  alignments:
    type: File
    format: http://edamontology.org/format_2572  # BAM
    inputBinding:
      prefix: -I
      position: 2
    secondaryFiles:
    - ^.bai
    doc: bam file, make sure it was aligned to the reference files used

outputs:
  depthOfCoverage:
    type: File[]
    outputBinding:
      glob: '*'
arguments:
- valueFrom: sample
  prefix: -o
  position: 2
- valueFrom: $(runtime.tmpdir)
  separate: false
  prefix: -Djava.io.tmpdir=
  position: 0
- valueFrom: DepthOfCoverage
  prefix: -T
  position: 2

baseCommand: [java]
doc: |
  GATK-DepthOfCoverage.cwl is developed for CWL consortium
  Assess sequence coverage by a wide array of metrics, partitioned by sample, read group, or library
    Usage: java -jar GenomeAnalysisTK.jar -T DepthOfCoverage -R reference.fasta -o file_name_base -I input_bams.list [-geneList refSeq.sorted.txt] [-pt readgroup] [-ct 4 -ct 6 -ct 10] [-L my_capture_genes.interval_list]

