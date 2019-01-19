# dnanexus_ngsapp

Dockerfile for DNA Nexus NGS tools

[![Docker Build Status](https://img.shields.io/docker/automated/sbamin/dnanexus_ngsapp.svg)](https://hub.docker.com/r/sbamin/dnanexus_ngsapp/) [![Docker Repository on Quay](https://quay.io/repository/sbamin/dnanexus_ngsapp/status "Docker Repository on Quay")](https://quay.io/repository/sbamin/dnanexus_ngsapp) [![GitHub release](https://img.shields.io/github/release/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.4) [![GitHub Issues](https://img.shields.io/github/issues/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/issues)

>19-Jan-2019   
>[v1.1.4](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.4)   

*   Source: https://github.com/sbamin/dnanexus_ngsapp
*   Docker Hub: https://hub.docker.com/r/sbamin/dnanexus_ngsapp
*   Quay: https://quay.io/repository/sbamin/dnanexus_ngsapp

### Pull and test image

```sh
docker pull sbamin/dnanexus_ngsapp
# OR
docker pull quay.io/sbamin/dnanexus_ngsapp
# OR
docker pull sbamin/dnanexus_ngsapp:1.1.4

docker run sbamin/dnanexus_ngsapp:1.1.4 "uname -a"
## Ubuntu 16.04
docker run sbamin/dnanexus_ngsapp:1.1.4 "whoami"
## Running  as non-root user, pallidus
docker run sbamin/dnanexus_ngsapp:1.1.4 "snakemake --help"
```

### Running workflows

Two modes to run: as root or with user id mapping to host machine.

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
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.4 "printf 'Hello World! I am '; id -a | tee -a /mnt/scratch/hello.txt"
```

*   Snakemake workflow for TitanCNA

>This will work only if mount volumes are properly set, and underlying directory structure is available. Read details inside configuration files at [TitanCNA - DNANexus](https://github.com/sbamin/TitanCNA/tree/dnanexus).

```sh
#!/bin/bash

set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="/mnt/scratch/lab/amins/docknexus/v2_20190118/mnts/scratch"
export DOCKEVO="/mnt/scratch/lab/amins/docknexus/v2_20190118/mnts/evocore"

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## Dry run snakemake
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.4 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m DRY | tee -a /mnt/scratch/testrun.log"

## Run snakemake
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.4 "cd /mnt/evocore/repos/TitanCNA/scripts/snakemake && ./run_snakemake_nexus.sh -m RUN | tee -a /mnt/scratch/testrun.log"
```

### User ID mapping

*   Using a different tag for user ID mapping. This is only available at `quay.io/sbamin/dnanexus_ngsapp:1.1.3`

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
