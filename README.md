# dnanexus_ngsapp

Dockerfile for DNA Nexus NGS tools

[![Docker Build Status](https://img.shields.io/docker/automated/sbamin/dnanexus_ngsapp.svg)](https://hub.docker.com/r/sbamin/dnanexus_ngsapp/) [![Docker Repository on Quay](https://quay.io/repository/sbamin/dnanexus_ngsapp/status "Docker Repository on Quay")](https://quay.io/repository/sbamin/dnanexus_ngsapp) [![GitHub release](https://img.shields.io/github/release/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.6) [![GitHub Issues](https://img.shields.io/github/issues/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/issues)

>21-Jan-2019   
>[v1.1.6](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.6)   

*   Source: https://github.com/sbamin/dnanexus_ngsapp
*   Docker Hub: https://hub.docker.com/r/sbamin/dnanexus_ngsapp
*   Quay: https://quay.io/repository/sbamin/dnanexus_ngsapp

### Pull and test image

```sh
docker pull sbamin/dnanexus_ngsapp:1.1.6
# OR
docker pull quay.io/sbamin/dnanexus_ngsapp:1.1.6 ## using quay image for dx app asset

docker run sbamin/dnanexus_ngsapp:1.1.6 "uname -a"
## Ubuntu 16.04
docker run sbamin/dnanexus_ngsapp:1.1.6 "whoami"
## Running  as non-root user, pallidus
docker run sbamin/dnanexus_ngsapp:1.1.6 "snakemake --help"
```

### Running workflows

*   Read [how-to-build-nexus-app.md](how-to-build-nexus-app.md) on building and running TITAN snakemake workflow on DNANexus nodes.

*   If using native docker image, there are two modes yoou can run snakemake workflow: as root or with user id mapping to host machine.

### To run as root

*   Hello World!

```sh
set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="$HOME/Downloads/dna_nexus/scratch"
export DOCKEVO="$HOME/Downloads/dna_nexus/evocore"

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## Using patched image
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.6 "printf 'Hello World! I am '; id -a | tee -a /mnt/scratch/hello.txt"
```

*   Snakemake workflow for TitanCNA

>This will work only if mount volumes are properly set, and underlying directory structure is available. Read details inside configuration files at [TitanCNA - DNANexus](https://github.com/sbamin/TitanCNA/tree/dnanexus).

```sh
#!/bin/bash

set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="/mnt/scratch/lab/amins/docknexus/v2_20190118/mnts/scratch"
export DOCKEVO="/mnt/scratch/lab/amins/docknexus/v2_20190118/mnts/evocore"

## dnanexus input dir
DXIN="$HOME"/in
## dnanexus output dir
DOCK_SMKOUT="$HOME"/out/snakemake

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## Dry run snakemake
docker run --rm --name dry_"$sample_id" -e R_LIBS="${SET_R_LIBS}" -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore -v "${DXIN}":/mnt/scratch/bam -v "${DOCK_SMKOUT}":/mnt/scratch/snakemake quay.io/sbamin/dnanexus_ngsapp:1.1.6 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m DRY -i $DOCK_SMK_CONFIG -s $sample_id -c $ncores | tee -a /mnt/scratch/snakemake/dryrun_$sample_id.log"

## Run snakemake
docker run --rm --name run_"$sample_id" -e R_LIBS="${SET_R_LIBS}" -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore -v "${DXIN}":/mnt/scratch/bam -v "${DOCK_SMKOUT}":/mnt/scratch/snakemake quay.io/sbamin/dnanexus_ngsapp:1.1.6 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m RUN -i $DOCK_SMK_CONFIG -s $sample_id -c $ncores | tee -a /mnt/scratch/snakemake/run_$sample_id.log"
```

### User ID mapping

*   Using a different tag for user ID mapping. Note that this may not work inside dnanexus. Also, it is only available in the image: `quay.io/sbamin/dnanexus_ngsapp:1.1.3`

```sh
set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="/home/foo/myscratch"
export DOCKEVO="/home/foo/evocore"

cd "${DOCKSCRATCH}"

## MAKE SURE TO GIVE PROPER USER AND GROUP IDs, matching to those of host machine
docker run -e HOSTUSER=$USER -e HOSTGROUP=$(id -gn $USER) -e HOSTUSERID=$UID -e HOSTGROUPID=$(id -g $USER) -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore quay.io/sbamin/dnanexus_ngsapp:1.1.3 "printf 'Hello World! I am '; id -a | tee -a /mnt/scratch/hello.txt"
```

>Resulting *hello.txt* file will be at "$DOCKSCRATCH"/hello.txt  

PS: In user id mapping mode, `/opt/bin/startup` will attempt to configure container environment, including userid mappings to host machine user:group id. If host user has `$DOCKEVO/configs/bin/startup` file and it is executable, then it will override internal `/opt/bin/startup` script. If you use custom startup script, make sure that it exits with `bash -c "$@"` or user id mapping directives as per `setup/bin/startup` and `setup/bin/userid_mapping.sh`.

_END_
