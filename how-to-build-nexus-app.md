## Building DNA Nexus App

Samir B. Amin, @sbamin
Sandeep Namburi, @snamburi3

*   [Building docker based dx app](https://wiki.dnanexus.com/Developer-Tutorials/Using-Docker-Images)
*   PS: Some of links may not be accessible to all as this is work in progress. We will push **[dx-app code](https://github.com/sbamin/dxapp_titancna_sjc)** to public once it runs on DNA Nexus platform.

### Create docker asset record

*   Login to RELU and activate dx env

```
ssh relu
source /opt/dx-toolkit/environment

dx login
dx select
## select SJC sponsorted bucket. Make sure to note Region from https://platform.dnanexus.com/projects, e.g., azure:west in this example.
```

*   Import docker image and ~~make an dx-asset~~

PS: Instead of creating asset for docker image (did not work for us), prefer saving tarball of docker image using `docker save -i quay.io/sbamin/dnanexus_ngsapp:1.1.6`. Upload this tarball to dnanexus project where you are buidling app or workflow. Then, we can reference this uploaded tar ball in dx-app-wizard (see below).

```
cd /mnt/scratch/lab/amins/docknexus
mkdir -p v2_dxapp/titancna_sjc_azwest && \
cd v2_dxapp/titancna_sjc_azwest

# dx-docker create-asset sbamin/dnanexus_ngsapp:1.1.4

dx-docker create-asset --ubuntu_version 16.04 --asset_version 0.9.4 quay.io/sbamin/dnanexus_ngsapp:1.1.6 |& tee -a create_asset_dnanexus_v0.9.4.log
```

*   Expected output:
    -   Note required json list below for `dxapp.json`

```
dx-docker create-asset --ubuntu_version 16.04 --asset_version 0.9.4 quay.io/sbamin/dnanexus_ngsapp:1.1.6 |& tee -a create_asset_dnanexus_v0.9.4.log
Exporting Docker image quay.io/sbamin/dnanexus_ngsapp:1.1.6
Extracting 21aacd39d68f
Extracting d812919e5f79
Extracting bb84666b3447
Extracting 082518d45819
Extracting d168942882ab
Extracting 100d9f9f33ba
Extracting c21b5de67f6d
Extracting 4fe4af637973
Extracting 45ee7ae864aa
Extracting cc5905d5a2ff
Extracting f3939fe574a2
Extracting cabe4b03b9f4
Extracting f3a80372b1ce
Extracting 72a94acfdc73
Extracting c3e5166671ed
Extracting dab08b2b97c3
Extracting 3d356303e470
Extracting 97999acb1dc3
Extracting bb15fae5e86b
Extracting db5af5b653cf
Extracting 2885aea12da7
Extracting 8a8a222fb6c2
Extracting 3d4612927ed3
Extracting 9f176a87a077
Building DNAnexus asset for quay.io/sbamin/dnanexus_ngsapp:1.1.6
Uploading DNAnexus asset for quay.io/sbamin/dnanexus_ngsapp:1.1.6
Image quay.io/sbamin/dnanexus_ngsapp:1.1.6 successfully cached in DNAnexus platform.
To include this cached image in an application, please include the following within the runspec/assetDepends list in your dxapp.json.
    {
        "project": "project-FFk15V89012BYGZ0K83QVz64",
        "folder": "/",
        "name": "quay.io/sbamin/dnanexus_ngsapp:1.1.6",
        "version": "0.9.4"
    }
```

### Create dx-app

*   [Manpage](https://wiki.dnanexus.com/dxapp.json)
*   [How-to guide](https://wiki.dnanexus.com/Developer-Tutorials/Intro-to-Building-Apps)

### Run app wizard

```sh
cd /mnt/scratch/lab/amins/docknexus/v2_dxapp

dx-app-wizard
```

Once we build default schema for a new app named, *titancna_sjc*, run `cd titancna_sjc && git init && git add --all && git commit -m "default app` within titancna_sjc directory to track changes to schema and other contents.

```sh
git diff
```
*   Making [following changes](https://github.com/sbamin/dxapp_titancna_sjc/commit/2bc14c50e71b2dc50bdf84c12aebcb59fa9f8f25) to *dxapp.json*

[From how-to guide](https://wiki.dnanexus.com/Developer-Tutorials/Intro-to-Building-Apps): When you use the DNAnexus build utility to build your applet, any files in the `titancna_sjc/resources` directory will be packaged as part of your applet and will be placed in the root directory of the virtual Linux PC whenever your applet is run in the cloud. Files placed in `titancna_sjc/resources/usr/bin` will therefore be put in `/usr/bin` in the container and be available in the default path at runtime. (Note: while the mytrimmer/resources subdirectory is unpacked into the root of the virtual filesystem, **your applet's executable will later start in `/home/dnanexus` as its current working directory.**

### Copy local resources

```
rsync -avhP /mnt/scratch/lab/amins/docknexus/v2_20190118/mnts/ <path to titancna_sjc>/resources/mnt/

cd titancna_sjc/resources
```

*  View directory structure under `titancna_sjc/resources` using `tree -d`

```
.
└── mnt
    ├── evocore ## mounted to /mnt/evocore inside docker container
    │   ├── configs
    │   │   └── bin ## scripts under this dir are exported to container PATH 
    │   └── repos ## required code for TITAN CNA goes here
    │       ├── ichorCNA
    │       │   ├── inst
    │       │   │   └── extdata
    │       │   ├── man
    │       │   ├── R
    │       │   └── scripts
    │       │       └── snakemake
    │       │           └── config
    │       └── TitanCNA
    │           ├── data
    │           ├── inst
    │           │   └── extdata
    │           ├── man
    │           ├── R
    │           ├── scripts
    │           │   ├── code -> snakemake/code
    │           │   ├── R_scripts
    │           │   ├── snakemake ## WORKDIR to run snakemake
    │           │   │   ├── code
    │           │   │   └── config
    │           │   └── TenX_scripts
    │           │       └── data
    │           ├── src
    │           └── vignettes
    └── scratch ## mounted to /mnt/scratch inside docker container
        ├── bam ## location where tumor and normal bam files are saved
        ├── refdata ## reference data
        └── tmp
```

### Make startup script

*   View startup script, `src/titancna_sjc.sh` at [app code directory](https://github.com/sbamin/dxapp_titancna_sjc)
*   This also required to make changes in snakemake workflow for TITAN. View those changes at [TITAN dnanexus branch](https://github.com/sbamin/TitanCNA/tree/dnanexus)

### Build App

```sh
# change to one level up from a path to titancna_sjc app directory
dx build titancna_sjc_azwest |& tee -a build_titancna_sjc_azwest.log
```

>{"id": "applet-FV2PGB89012K3XKz6499Fkvx"}  

### View summary

```
dx describe titancna_sjc_azwest
```

### To test run

*   Save output to an existing TITANCNA directory in dnanexus project. Project is same as where app is installed.

```
dx run --ssh --destination TITANCNA -f example_run_input.json titancna_sjc_azwest
```

END
