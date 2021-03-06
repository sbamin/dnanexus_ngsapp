#!/bin/bash

set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="/mnt/scratch/lab/amins/docknexus/v2_dxapp/titancna_sjc_azwest/resources/mnt/scratch"
export DOCKEVO="/mnt/scratch/lab/amins/docknexus/v2_dxapp/titancna_sjc_azwest/resources/mnt/evocore"

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## Dry run snakemake
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore quay.io/sbamin/dnanexus_ngsapp:1.1.6 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m DRY | tee -a /mnt/scratch/testrun.log"

## Run snakemake
# docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.4 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m RUN | tee -a /mnt/scratch/testrun.log"

## END ##
