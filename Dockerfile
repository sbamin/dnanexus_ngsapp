############################################################
# Dockerfile to build docker image: sbamin/dnanexus_ngsapp
# Author: Samir B. Amin
# GitHub: @sbamin
############################################################

FROM sbamin/dnanexus_ngsapp:1.1.3

## For questions, visit https:
MAINTAINER "Samir B. Amin" <tweet:sbamin; sbamin.com/contact>

LABEL version="1.1.3p1" \
      mode="devp version for DNA Nexus Computing" \   
      description="docker image to run workflows on DNA Nexus Platform. Run as root" \
      contributor1="Sandeep Namburi, GitHub @snamburi3" \
      website="https://verhaaklab.com" \
      code="https://github.com/sbamin/dnanexus_ngsapp" \
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

####### Override userid mapping #######
## run container as a root
ADD ./setup/ /tempdir/

## override original startup script with barebone startup to run native commands as root.
RUN ls -alh /tempdir/* && \
       rsync -avhP /tempdir/bin/reset_startup /opt/bin/startup && \
       rsync -avhP /tempdir/LICENSE /LICENSE && \
       chmod 755 /opt/bin/startup && \
       rm -rf /tempdir

## /mnt/scratch where container can store downloaded/generated data
## use docker volume mount option to mount host directory to docker:/mnt/scratch
WORKDIR        /mnt/scratch

## startup helper script
ENTRYPOINT ["/opt/bin/startup"]
CMD ["/bin/uname", "-a"]

## END ##
