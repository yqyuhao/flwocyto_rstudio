FROM ubuntu:22.04

MAINTAINER yuhao<yqyuhao@outlook.com>

RUN sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/mirrors\.aliyun\.com\/ubuntu\//g' /etc/apt/sources.list

# set timezone
RUN set -x \
&& export DEBIAN_FRONTEND=noninteractive \
&& apt-get update \
&& apt-get install -y tzdata \
&& ln -sf /usr/share/zoneinfo/Asia/Shanghai  /etc/localtime \
&& echo "Asia/Shanghai" > /etc/timezone

# install packages
RUN apt-get update \

&& apt-get install -y less curl apt-utils vim wget gcc-9 g++-9 make cmake git unzip dos2unix libncurses5 \

# lib
&& apt-get install -y zlib1g-dev libjpeg-dev libncurses5-dev libbz2-dev liblzma-dev libcurl4-gnutls-dev libssl-dev libgeos-dev \
 
# python3 perl java r-base
&& apt-get install -y python3 python3-dev python3-pip perl openjdk-8-jdk r-base r-base-dev 

ENV software /yqyuhao

# create software folder
RUN mkdir -p $software/database $software/bin /data /data/analysis 

# install R packages
WORKDIR $software
RUN Rscript -e "install.packages(c('BiocManager','dplyr','readxl','cowplot','ggplot2'));BiocManager::install(c('Seurat','flowCore'), update = TRUE, ask = FALSE)"

# copy esssential files
WORKDIR $software

# chown root:root
WORKDIR $software
RUN chown root:root -R $software

# Rstudio server
RUN apt-get install -y gdebi-core
RUN wget https://download2.rstudio.org/server/jammy/amd64/rstudio-server-2022.07.1-554-amd64.deb
RUN gdebi -q rstudio-server-2022.07.1-554-amd64.deb

# add user
RUN useradd flowcyto -m -s /bin/bash
RUN echo "flowcyto:password" | chpasswd

# mkdir fastq directory and analysis directory
WORKDIR /data/analysis
