############################################################
# Dockerfile to build docker image: sbamin/dnanexus_ngsapp
# Author: Samir B. Amin
# GitHub: @sbamin
############################################################

FROM ubuntu:16.04

## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

LABEL version="1.1.3" \
      mode="devp version for DNA Nexus Computing" \   
      description="docker image to run workflows on DNA Nexus Platform" \
      contributor1="Sandeep Namburi, GitHub @snamburi3" \
      website="https://verhaaklab.com" \
      code="https://github.com/TheJacksonLaboratory/dnanexus_ngsapp" \
      contact="Samir Amin, @sbamin" \
      NOTICE="Third party integrations were used for a list of tools from ftp://ftp.jax.org/verhaak/deps/"

## echo -e "\n#####\nSet Env\n#####\n"
ENV PATH=/opt/miniconda/bin:/opt/bin:/home/evo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin"${PATH:+:$PATH}" \
    JAVA_HOME=/usr/lib/jvm/java \
    J2SDKDIR=/usr/lib/jvm/java \
    J2REDIR=/usr/lib/jvm/java/jre \
    JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server \
    JDK7=/opt/java/jdk7 \
    JDK8=/opt/java/jdk8 \
    TZ=Etc/UTC \
    LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server"${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

## export PATH JAVA_HOME J2SDKDIR J2REDIR JAVA_LD_LIBRARY_PATH JDK7 JDK8 TZ LD_LIBRARY_PATH

ENV LC_ALL=en_US.UTF-8 \
    LANG=en_US.UTF-8 \
    TZ=Etc/UTC \
    DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true

RUN echo $TZ >| /etc/timezone

## echo -e "\n#####\nInstall devtools\n#####\n"
RUN umask 0022 && \
apt-get update && apt-get install --yes --no-install-recommends apt-utils \
	build-essential python-software-properties \
	python-setuptools sudo locales ca-certificates tzdata \
	software-properties-common cmake libcurl4-openssl-dev wget curl \
	gdebi tar zip unzip rsync tmux screen nano vim dos2unix bc \
	libxml2-dev libssl-dev dpkg-dev libx11-dev libxpm-dev libxft-dev \
	libxext-dev libpng-dev libjpeg-dev binutils libncurses-dev zlib1g-dev libbz2-dev \
	liblzma-dev ruby libarchive-zip-perl libdbd-mysql-perl libjson-perl gfortran libpcre3-dev autoconf

## echo -e "\n#####\nInstall devtools\n#####\n"
RUN add-apt-repository --yes ppa:git-core/ppa && \
	apt-get update && apt-get install --yes --no-install-recommends git

## echo -e "\n#####\nSetup locale and time-zone\n#####\n"
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
	locale-gen en_US.utf8 && \
	/usr/sbin/update-locale LANG=en_US.UTF-8 && \
	echo "TZ is $TZ" && \
	rm -f /etc/localtime && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	dpkg-reconfigure -f noninteractive tzdata

## echo -e "\n#####\nSetup non-root user\n#####\n"
RUN groupadd -g 712119 evo && \
	useradd -m -d /home/evo -s /bin/bash -c "GLASS Default User" -u 2119518 -g evo -G staff,sudo pallidus && \
	echo "%sudo  ALL=(ALL) NOPASSWD:ALL" | (EDITOR="tee -a" visudo)

## echo -e "\n#####\nInstall Conda\n#####\n"
RUN mkdir -p /opt/bin && \
	wget --no-check-certificate https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /opt/miniconda.sh && \
	bash /opt/miniconda.sh -b -p /opt/miniconda -f && \
	rm -f /opt/miniconda.sh

## echo -e "\n#####\nOverride system python with conda python\n#####\n"
## echo -e "\n#####\nSetup startup env\n#####\n"
RUN echo 'PATH=/opt/miniconda/bin:/opt/bin:/home/evo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin' >> /etc/profile.d/zz_set_env.sh && \
	echo 'JAVA_HOME=/usr/lib/jvm/java' >> /etc/profile.d/zz_set_env.sh && \
	echo 'J2SDKDIR=/usr/lib/jvm/java' >> /etc/profile.d/zz_set_env.sh && \
	echo 'J2REDIR=/usr/lib/jvm/java/jre' >> /etc/profile.d/zz_set_env.sh && \
	echo 'JAVA_LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server' >> /etc/profile.d/zz_set_env.sh && \
	echo 'JDK7=/opt/java/jdk7\nJDK8=/opt/java/jdk8' >> /etc/profile.d/zz_set_env.sh && \
	echo 'LD_LIBRARY_PATH=/usr/lib/jvm/java/jre/lib/amd64/server' >> /etc/profile.d/zz_set_env.sh && \
	echo 'export PATH JAVA_HOME J2SDKDIR J2REDIR JAVA_LD_LIBRARY_PATH JDK7 JDK8 LD_LIBRARY_PATH' >> /etc/profile.d/zz_set_env.sh

## conda bugfix: https://stackoverflow.com/a/46498173/1243763 
RUN conda update --yes conda && conda update --yes python && \
	conda config --add channels conda-forge && \
	conda config --add channels defaults && \
	conda config --add channels r && \
	conda config --add channels bioconda

## echo -e "\n#####\nSetup JDK8\n#####\n"
RUN mkdir -p /opt/java && \
	cd /opt/java && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/jdk-8u151-linux-x64.tar.gz && \
	tar xvzf jdk-8u151-linux-x64.tar.gz && \
	ln -s jdk1.8.0_151 jdk8 && \
	rm -f jdk-8u151-linux-x64.tar.gz && \
	cd /opt/java/jdk1.8.0_151/lib/amd64 && \
	ln -s ../../jre/lib/amd64/server ./server && \
	mkdir -p /usr/lib/jvm && \
	cd /usr/lib/jvm && \
	ln -s /opt/java/jdk8 java

## echo -e "\n#####\nSetup JDK7\n#####\n"
RUN cd /opt/java && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/jdk1.7.0_79.tar.gz && \
	tar xvzf jdk1.7.0_79.tar.gz && \
	ln -s jdk1.7.0_79 jdk7 && \
	rm -f jdk1.7.0_79.tar.gz

## echo -e "\n#####\nPush jar files\n#####\n"
RUN mkdir -p /opt/jars && \
	cd /opt/jars && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/picard.jar && \
	wget --no-check-certificate https://github.com/broadinstitute/gatk/releases/download/4.0.9.0/gatk-4.0.9.0.zip && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/VarScan.v2.4.2.jar && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/mutect-1.1.7.jar && \
	chown -R root:evo /opt/jars && \
	chmod 644 /opt/jars/*.jar

## echo -e "\n#####\nInstall R and other tools from conda\n#####\n"
RUN conda install --yes samtools bcftools bedtools biopython bioconductor-titancna snakemake pysam pyyaml

## echo -e "\n#####\nInstall R packages\n#####\n"
RUN Rscript -e 'install.packages(c("tidyverse", "git2r", "stringr", "devtools", "optparse"), repos = c(CRAN="http://cran.rstudio.com"))' && \
	Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite('HMMcopy', suppressUpdates=TRUE)" && \
	Rscript -e "source('http://bioconductor.org/biocLite.R');biocLite('SNPchip', suppressUpdates=TRUE)" && \
	cd /opt && \
	git clone https://github.com/broadinstitute/ichorCNA.git && \
	cd ichorCNA && \
	R CMD INSTALL . && \
	cd /opt

## echo -e "\n#####\nInstall rjava package\n#####\n"
RUN ln -s /opt/java/jdk8/jre/lib/amd64/server/libjvm.so /opt/miniconda/lib/ && \
	R CMD javareconf && \
	conda install --yes r-rjava

## echo -e "\n#####\nInstall TitanCNA\n#####\n"
RUN cd /opt && \
	git clone https://github.com/gavinha/TitanCNA.git && \
	cd /opt

## echo -e "\n#####\nInstall smoove et al.\n#####\n"

## ToDo: Fix svtools and svtyper install
## Don't install via pip as these requires python2
#pip install git+https://github.com/hall-lab/svtyper.git
#pip install svtools
## instead make a python2 env and dirty way to symlink in default, py3 bin/
RUN conda create --yes -n smoove smoove && \
	cd /opt/miniconda/bin && \
	ln -s ../envs/smoove/bin/svtyper ./ && \
	ln -s ../envs/smoove/bin/svtools ./ && \
	cd /opt && \
	git clone --recursive https://github.com/arq5x/lumpy-sv.git && \
	cd lumpy-sv && \
	make && \
	cp bin/* /usr/local/bin/. && \
	cd /opt && \
	git clone https://github.com/GregoryFaust/samblaster.git && \
	cd samblaster && \
	make && \
	cp samblaster /usr/local/bin/. && \
	cd /opt && \
	wget --no-check-certificate http://mirrors.kernel.org/ubuntu/pool/main/g/gawk/gawk_4.1.3+dfsg-0.1_amd64.deb && \
	dpkg -i gawk_4.1.3+dfsg-0.1_amd64.deb && \
	rm gawk_4.1.3+dfsg-0.1_amd64.deb && \
	cd /opt && \
	mkdir -p /opt/sambamba && \
	cd /opt/sambamba && \
	wget --no-check-certificate https://github.com/biod/sambamba/releases/download/v0.6.8/sambamba-0.6.8-linux-static.gz && \
	gunzip -c sambamba-0.6.8-linux-static.gz >| sambamba && \
	chmod 755 sambamba && \
	cp sambamba /usr/local/bin/. && \
	cd /opt && \
	rm -rf /opt/sambamba && \
	cd /opt/bin && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/gsort && \
	chmod 755 gsort && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/mosdepth && \
	chmod 755 mosdepth && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/duphold && \
	chmod 755 duphold && \
	wget --no-check-certificate ftp://ftp.jax.org/verhaak/deps/smoove && \
	chmod 755 smoove

## echo -e "\n#####\nInstall freebayes\n#####\n" && \
RUN mkdir -p /opt/freebayes && \
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

## echo -e "\n#####\nSetup Disk Mounts\n#####\n"
RUN mkdir -p /mnt/scratch/refdata && \
	mkdir -p /mnt/scratch/logs && \
	mkdir -p /mnt/evocore && \
	mkdir -p /mnt/evocore/configs/bin && \
	mkdir -p /mnt/evocore/configs/profile.d && \
	mkdir -p /mnt/evocore/configs/extapps && \
	mkdir -p /mnt/evocore/configs/extapps/Rpkgs && \
	mkdir -p /mnt/evocore/workflows && \
	mkdir -p /mnt/evodata/tmp && \
	mkdir -p /mnt/evodata/flowr && \
	chown -R pallidus:evo /mnt/scratch && \
	chown -R pallidus:evo /mnt/evocore && \
	chown -R pallidus:evo /mnt/evodata && \
	chmod -R 775 /mnt/scratch && \
	chmod -R 775 /mnt/evocore && \
	chmod -R 775 /mnt/evodata

## echo -e "\n#####\nCleanup\n#####\n"
RUN apt-get clean && \
	rm -rf /var/lib/apt/lists/* && \
	conda clean --yes --all

## Set PATH and Helper scripts to start container with non-root and host user:group attributes
## ToDo: Based on https://github.com/sbamin/gdc-client/blob/master/Dockerfile
ENV PATH=/opt/miniconda/bin:/opt/bin:/home/evo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/freebayes/default/bin:/usr/lib/jvm/java/bin:/usr/lib/jvm/java/db/bin:/usr/lib/jvm/java/jre/bin"${PATH:+:$PATH}"

####### Setup non-root docker env #######
## copy setup files in the container ##
ADD ./setup/ /tempdir/

RUN ls -alh /tempdir/* && \
	chmod 755 /etc/profile.d/*.sh && \
	mkdir -p /opt/bin && \
	rsync -avhP /tempdir/bin/ /opt/bin/ && \
	chmod 755 /opt/bin/startup && \
	chmod 755 /opt/bin/userid_mapping.sh && \
	rm -rf /tempdir

## /mnt/scratch where container can store downloaded/generated data
## use docker volume mount option to mount host directory to docker:/mnt/scratch
WORKDIR	/mnt/scratch

## startup helper script
ENTRYPOINT ["/opt/bin/startup"]
CMD ["/bin/uname", "-a"]

## END ##
