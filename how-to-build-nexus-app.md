## Building DNA Nexus App

>[Building docker based dx app](https://wiki.dnanexus.com/Developer-Tutorials/Using-Docker-Images)  

### Create docker asset record

*   Login to RELU and activate dx env

```
ssh relu
source /opt/dx-toolkit/environment
```

*   Import docker image and make an dx-asset

```
cd /mnt/scratch/lab/amins/docknexus
mkdir -p v2_dxapp && cd v2_dxapp

dx-docker create-asset sbamin/dnanexus_ngsapp:1.1.4
```

*   Expected output:
    -   Note required json list below for `dxapp.json`

```
Exporting Docker image sbamin/dnanexus_ngsapp:1.1.4
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
Extracting f68bf914769c
Building DNAnexus asset for sbamin/dnanexus_ngsapp:1.1.4
Uploading DNAnexus asset for sbamin/dnanexus_ngsapp:1.1.4
Image sbamin/dnanexus_ngsapp:1.1.4 successfully cached in DNAnexus platform.
To include this cached image in an application, please include the following within the runspec/assetDepends list in your dxapp.json.
    {
        "project": "project-FV1Zq1Q0PfpFkJ2J3vJKP5XF",
        "folder": "/",
        "name": "sbamin/dnanexus_ngsapp:1.1.4",
        "version": "0.0.1"
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
