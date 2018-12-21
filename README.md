# dnanexus_ngsapp

Dockerfile for DNA Nexus NGS tools

[![Docker Build Status](https://img.shields.io/docker/automated/sbamin/dnanexus_ngsapp.svg)](https://hub.docker.com/r/sbamin/dnanexus_ngsapp/) [![Docker Repository on Quay](https://quay.io/repository/sbamin/dnanexus_ngsapp/status "Docker Repository on Quay")](https://quay.io/repository/sbamin/dnanexus_ngsapp) [![GitHub release](https://img.shields.io/github/release/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.3) [![GitHub Issues](https://img.shields.io/github/issues/sbamin/dnanexus_ngsapp.svg)](https://github.com/sbamin/dnanexus_ngsapp/issues)

>20-Dec-2018   
>[v1.1.3](https://github.com/sbamin/dnanexus_ngsapp/releases/tag/v1.1.3)   

*   Source: https://github.com/sbamin/dnanexus_ngsapp
*   Docker Hub: https://hub.docker.com/r/sbamin/dnanexus_ngsapp
*   Quay: https://quay.io/repository/sbamin/dnanexus_ngsapp

### Pull and test image

```sh
docker pull sbamin/dnanexus_ngsapp
# OR
docker pull quay.io/sbamin/dnanexus_ngsapp
# OR
docker pull quay.io/sbamin/dnanexus_ngsapp:1.1.3

docker run quay.io/sbamin/dnanexus_ngsapp:1.1.3 "uname -a"
## Ubuntu 16.04
docker run quay.io/sbamin/dnanexus_ngsapp:1.1.3 "whoami"
## Running  as non-root user, pallidus
docker run quay.io/sbamin/dnanexus_ngsapp:1.1.3 "snakemake --help"
```

### Running workflows

PS: `/opt/bin/startup` will attempt to configure container environment, including userid mappings to host machine user:group id. If host user has `$DOCKEVO/configs/bin/startup` file and it is executable, then it will override internal `/opt/bin/startup` script. If you use custom startup script, make sure that it exits with `bash -c "$@"` or user id mapping directives as per `setup/bin/startup` and `setup/bin/userid_mapping.sh`.

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

### To run as root

```sh
set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="$HOME/Downloads/dna_nexus/scratch"
export DOCKEVO="$HOME/Downloads/dna_nexus/evocore"

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## Using patched image
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.3p1 "printf 'Hello World! I am '; id -a | tee -a /mnt/scratch/hello.txt"
```

_END_
