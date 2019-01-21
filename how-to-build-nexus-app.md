## Building DNA Nexus App

Samir B. Amin, @sbamin
Sandeep Namburi, @snamburi3

*   [Building docker based dx app](https://wiki.dnanexus.com/Developer-Tutorials/Using-Docker-Images)
*   PS: Some of links may not be accessible to all as this is work in progress. We will push dx-app code to public once it runs on DNA Nexus platform.

### Create docker asset record

*   Login to RELU and activate dx env

```
ssh relu
source /opt/dx-toolkit/environment

dx login
dx select
## select SJC sponsorted bucket. Make sure to note Region from https://platform.dnanexus.com/projects, e.g., azure:west in this example.
```

*   Import docker image and make an dx-asset

```
cd /mnt/scratch/lab/amins/docknexus
mkdir -p v2_dxapp/titancna_sjc_azwest && \
cd v2_dxapp/titancna_sjc_azwest

# dx-docker create-asset sbamin/dnanexus_ngsapp:1.1.4

dx-docker create-asset --ubuntu_version 16.04 --asset_version 0.9.3 sbamin/dnanexus_ngsapp:1.1.5 |& tee -a create_asset_dnanexus_v0.9.3.log
```

*   Expected output:
    -   Note required json list below for `dxapp.json`

```
Exporting Docker image sbamin/dnanexus_ngsapp:1.1.5
Extracting 0b82eda5673a
Extracting ca7d258f6606
Extracting d50c408b1317
Extracting fbe0c1589b0c
Extracting 5dba089da61a
Extracting abf5aa11bce6
Extracting 7ee8a060c26d
Extracting c95632cc2a20
Extracting ca383520045d
Extracting 5aafd5af1064
Extracting 4b1000767ccd
Extracting 18fa0444de26
Extracting 476df6201683
Extracting e1974e321e66
Extracting 21b92109f4cc
Extracting b032c4d173f9
Extracting 6e1b094d03b2
Extracting 9871f2a50540
Extracting d441b8ad9ff2
Extracting d73f7b2c385a
Extracting fcb26dadf64f
Extracting 36ae91a54e9f
Extracting a6fa9fdc397f
Extracting 974777ffcea8
Extracting dd64cd7078c9
Extracting 45cdf1359e6d
Extracting 8025292e7558
Extracting 40c7376974af
Extracting 94b88b8bd231
Extracting 8c7651a7f523
Extracting 26d8028297ca
Building DNAnexus asset for sbamin/dnanexus_ngsapp:1.1.5
Uploading DNAnexus asset for sbamin/dnanexus_ngsapp:1.1.5
Image sbamin/dnanexus_ngsapp:1.1.5 successfully cached in DNAnexus platform.
To include this cached image in an application, please include the following within the runspec/assetDepends list in your dxapp.json.
    {
        "project": "project-FFk15V89012BYGZ0K83QVz64",
        "folder": "/",
        "name": "sbamin/dnanexus_ngsapp:1.1.5",
        "version": "0.9.3"
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

```
dx run titancna_sjc_azwest -f example_run_input.json
```

END
