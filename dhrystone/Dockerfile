FROM ubuntu:14.04
MAINTAINER xjimmy@mc2.io

ENV BASE_DIR /root
ENV PATH=/usr/local/bin:$PATH


# backup old sources.list
RUN rm /etc/apt/sources.list

############################################################
# update source.list
############################################################
RUN echo "deb http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse" > /etc/apt/sources.list && \
    #echo "deb http://mirrors.163.com/ubuntu/ trusty-security main restricte universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty main restricted universe multiverse" >> /etc/apt/sources.list && \
    #echo "deb-src http://mirrors.163.com/ubuntu/ trusty-security main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-updates main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-proposed main restricted universe multiverse" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/ubuntu/ trusty-backports main restricted universe multiverse" >> /etc/apt/sources.list

RUN export DEBIAN_FRONTEND=noninteractive && \
	apt-get -y clean && \
	apt-get -y update

############################################################
# install common packages
############################################################
RUN apt-get -y install git make automake libc6-dev libtool dos2unix

############################################################
# compile sysbench from source
############################################################
WORKDIR $BASE_DIR
RUN git clone https://github.com/Jimmy-Xu/dhrystone-deb.git
WORKDIR ${BASE_DIR}/dhrystone-deb
RUN git checkout mine
RUN make
RUN if [ -f dhry ];then echo "build dhrystone success"; else echo "build dhrystone failed"; exit 1; fi


