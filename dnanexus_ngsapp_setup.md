## DNA Nexus Asset 

>Build Instructions

```
ssh relu
mkdir -p /mnt/scratch/lab/amins/docknexus
docker run -it --name nexus -v /mnt/scratch/lab/amins/docknexus:/scratch ubuntu:16.04 /bin/bash
```

### Inside nexus container

*   See [Singularity image file for GLASS project](https://raw.githubusercontent.com/glass-consortium/glasstools/master/build/Singularity.beta)

```bash
echo -e "\n#####\nSet Env\n#####\n"

PATH=/opt/miniconda/bin:/opt/bin:/home/glass/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin"${PATH:+:$PATH}"

JAVA_HOME=/usr/lib/jvm/java
J2SDKDIR=/usr/lib/jvm/java
J2REDIR=/usr/lib/jvm/java/jre
JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server
JDK7=/opt/java/jdk7
JDK8=/opt/java/jdk8
TZ=Etc/UTC
LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server"${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

export PATH JAVA_HOME J2SDKDIR J2REDIR JAVA_LD_LIBRARY_PATH JDK7 JDK8 TZ LD_LIBRARY_PATH

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export TZ=Etc/UTC
echo $TZ >| /etc/timezone

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

echo -e "\n#####\nInstall devtools\n#####\n"
umask 0022 && \
apt-get update && apt-get install --yes --no-install-recommends apt-utils \
  build-essential python-software-properties \
  python-setuptools sudo locales ca-certificates tzdata \
  software-properties-common cmake libcurl4-openssl-dev wget curl \
  gdebi tar zip unzip rsync tmux screen nano vim dos2unix bc \
  libxml2-dev libssl-dev dpkg-dev libx11-dev libxpm-dev libxft-dev \
  libxext-dev libpng-dev libjpeg-dev binutils libncurses-dev zlib1g-dev libbz2-dev \
  liblzma-dev ruby libarchive-zip-perl libdbd-mysql-perl libjson-perl gfortran libpcre3-dev autoconf

echo -e "\n#####\nInstall devtools\n#####\n"
add-apt-repository --yes ppa:git-core/ppa
apt-get update && apt-get install --yes --no-install-recommends git

echo -e "\n#####\nSetup locale\n#####\n"
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen en_US.utf8
/usr/sbin/update-locale LANG=en_US.UTF-8

echo -e "\n#####\nSetup Timezone\n#####\n"
echo "TZ is $TZ"
rm -f /etc/localtime && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

echo -e "\n#####\nSetup glassuser\n#####\n"
groupadd -g 712119 glass && \
useradd -m -d /home/glass -s /bin/bash -c "GLASS Default User" -u 2119518 -g glass -G staff,sudo glassuser && \
echo "%sudo  ALL=(ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)

echo -e "\n#####\nInstall Conda\n#####\n"
mkdir -p /opt/bin && \
wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/miniconda.sh && \
bash /opt/miniconda.sh -b -p /opt/miniconda -f && \
rm -f /opt/miniconda.sh

echo -e "\n#####\nOverride system python with conda python\n#####\n"
PATH=/opt/miniconda/bin:/opt/bin:/home/glass/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin

export PATH

echo -e "\n#####\nSetup startup env\n#####\n"
printf "PATH=/opt/miniconda/bin:/opt/bin:/home/glass/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin\n" >> /etc/profile.d/zz_set_env.sh

printf "JAVA_HOME=/usr/lib/jvm/java\nJ2SDKDIR=/usr/lib/jvm/java\nJ2REDIR=/usr/lib/jvm/java/jre\nJAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server\nJDK7=/opt/java/jdk7\nJDK8=/opt/java/jdk8\nLD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server\n" >> /etc/profile.d/zz_set_env.sh

printf "export PATH JAVA_HOME J2SDKDIR J2REDIR JAVA_LD_LIBRARY_PATH JDK7 JDK8 LD_LIBRARY_PATH\n" >> /etc/profile.d/zz_set_env.sh

## conda bugfix: https://stackoverflow.com/a/46498173/1243763 
conda update --yes conda && conda update --yes python

conda config --add channels conda-forge && \
conda config --add channels defaults && \
conda config --add channels r && \
conda config --add channels bioconda

echo -e "\n#####\nSetup JDK8\n#####\n"
mkdir -p /opt/java
cd /opt/java
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/jdk-8u151-linux-x64.tar.gz
tar xvzf jdk-8u151-linux-x64.tar.gz
ln -s jdk1.8.0_151 jdk8
rm -f jdk-8u151-linux-x64.tar.gz
cd /opt/java/jdk1.8.0_151/lib/amd64
ln -s ../../jre/lib/amd64/server ./server
mkdir -p /usr/lib/jvm
cd /usr/lib/jvm
ln -s /opt/java/jdk8 java

echo -e "\n#####\nSetup JDK7\n#####\n"
cd /opt/java
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/jdk1.7.0_79.tar.gz
tar xvzf jdk1.7.0_79.tar.gz
ln -s jdk1.7.0_79 jdk7
rm -f jdk1.7.0_79.tar.gz

echo -e "\n#####\nPush jar files\n#####\n"
mkdir -p /opt/jars
cd /opt/jars
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/picard.jar
wget --no-check-certificate https://github.com/broadinstitute/gatk/releases/download/4.0.9.0/gatk-4.0.9.0.zip
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/VarScan.v2.4.2.jar
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/mutect-1.1.7.jar
chown -R root:glass /opt/jars
chmod 644 /opt/jars/*.jar

echo -e "\n#####\nInstall R and other tools from conda\n#####\n"
conda install --yes samtools bcftools bedtools biopython bioconductor-titancna snakemake pysam pyyaml

echo -e "\n#####\nInstall R packages\n#####\n"
  Rscript -e 'install.packages(c("tidyverse", "git2r", "stringr", "devtools", "optparse"), repos = c(CRAN="http://cran.rstudio.com"))'

echo -e "\n#####\nInstall bioconductor packages\n#####\n"  
Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite('HMMcopy', suppressUpdates=TRUE)"

Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite('SNPchip', suppressUpdates=TRUE)"

cd /opt && \
git clone https://github.com/broadinstitute/ichorCNA.git && \
cd ichorCNA && \
R CMD INSTALL . && \
cd /opt

echo -e "\n#####\nInstall rjava package\n#####\n"
ln -s /opt/java/jdk8/jre/lib/amd64/server/libjvm.so /opt/miniconda/lib/
R CMD javareconf
conda install --yes r-rjava

echo -e "\n#####\nInstall TitanCNA\n#####\n"
cd /opt && \
git clone https://github.com/gavinha/TitanCNA.git && \
cd /

echo -e "\n#####\nInstall smoove et al.\n#####\n"

## ToDo: Fix svtools and svtyper install
## Don't install via pip as these requires python2
#pip install git+https://github.com/hall-lab/svtyper.git
#pip install svtools
## instead make a python2 env and dirty way to symlink in default, py3 bin/
conda create --yes -n smoove smoove && \
cd /opt/miniconda/bin && \
ln -s ../envs/smoove/bin/svtyper ./ && \
ln -s ../envs/smoove/bin/svtools ./ && \
cd /opt

git clone --recursive https://github.com/arq5x/lumpy-sv.git && \
cd lumpy-sv && \
make && \
cp bin/* /usr/local/bin/. && \
cd /opt

git clone https://github.com/GregoryFaust/samblaster.git && \
cd samblaster && \
make && \
cp samblaster /usr/local/bin/. && \
cd /opt

wget --no-check-certificate http://mirrors.kernel.org/ubuntu/pool/main/g/gawk/gawk_4.1.3+dfsg-0.1_amd64.deb && \
dpkg -i gawk_4.1.3+dfsg-0.1_amd64.deb && \
rm gawk_4.1.3+dfsg-0.1_amd64.deb && \
cd /opt

mkdir -p /opt/sambamba && \
cd /opt/sambamba && \
wget --no-check-certificate https://github.com/biod/sambamba/releases/download/v0.6.8/sambamba-0.6.8-linux-static.gz && \
gunzip -c sambamba-0.6.8-linux-static.gz > sambamba && \
chmod 755 sambamba && \
cp sambamba /usr/local/bin/. && \
cd /opt && \
rm -rf /opt/sambamba

cd /opt/bin && \
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/gsort && \
chmod 755 gsort && \
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/mosdepth && \
chmod 755 mosdepth && \
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/duphold && \
chmod 755 duphold && \
wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/smoove && \
chmod 755 smoove

echo -e "\n#####\nInstall freebayes\n#####\n" && \
mkdir -p /opt/freebayes && \
cd /opt/freebayes && \
mkdir -p fb_seqlib && \
mkdir -p fb_bamtools && \
git clone --recursive https://github.com/ekg/freebayes.git source && \
cd /opt/freebayes/source && \
make && \
cd /opt/freebayes && \
rm -rf source/vcflib/samples && \
rm -rf source/src && \
rm -rf source/bamtools && \
rm -rf source/.git && \
rm -rf source/vcflib/googletest && \
rm -rf source/vcflib/paper && \
rm -rf source/SeqLib/src && \
rm -rf source/SeqLib/htslib/test && \
rm -rf source/vcflib/tabixpp/htslib/test && \
rsync -avhP source/ fb_seqlib/ && \
ln -s fb_seqlib default && \
rm -rf source && \
cd fb_seqlib && \
chmod 755 scripts/sam_add_rg.pl && \
rsync -avhP scripts/ bin/ && \
cd /opt

echo -e "\n#####\nSetup Disk Mounts\n#####\n"
mkdir -p /mnt/scratch/refdata && \
mkdir -p /mnt/scratch/logs && \
mkdir -p /mnt/glasscore && \
mkdir -p /mnt/glasscore/configs/bin && \
mkdir -p /mnt/glasscore/configs/profile.d && \
mkdir -p /mnt/glasscore/configs/extapps && \
mkdir -p /mnt/glasscore/configs/extapps/Rpkgs && \
mkdir -p /mnt/glasscore/workflows && \
mkdir -p /mnt/glassdata/tmp && \
mkdir -p /mnt/glassdata/flowr && \
chown -R glassuser:glass /mnt/scratch && \
chown -R glassuser:glass /mnt/glasscore && \
chown -R glassuser:glass /mnt/glassdata && \
chmod -R 775 /mnt/scratch && \
chmod -R 775 /mnt/glasscore && \
chmod -R 775 /mnt/glassdata

echo -e "\n#####\nCleanup\n#####\n"
apt-get clean
rm -rf /var/lib/apt/lists/*
conda clean --yes --all
```
