#!/bin/bash

set -euo pipefail

## path where data will be stored on the host machine
export DOCKSCRATCH="$HOME/Downloads/dna_nexus/scratch"
export DOCKEVO="$HOME/Downloads/dna_nexus/evocore"

mkdir -p "$DOCKSCRATCH"
mkdir -p "$DOCKEVO"

cd "${DOCKSCRATCH}"

## MAKE SURE TO GIVE PROPER USER AND GROUP IDs, matching to those of host machine
docker run -v "${DOCKSCRATCH}":/mnt/scratch -v "${DOCKEVO}":/mnt/evocore sbamin/dnanexus_ngsapp:1.1.3p1 "printf 'Hello World! I am '; id -a | tee -a /mnt/scratch/hello.txt"

## END ##
