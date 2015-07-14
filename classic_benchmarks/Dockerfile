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
RUN git clone https://github.com/Jimmy-Xu/classic_benchmarks.git
WORKDIR ${BASE_DIR}/classic_benchmarks/source_code
RUN make
RUN sleep 1
#RUN if [ -f dhry1 -a -f dhry2 -a -f whets -a -f lpack ];then echo "build classic_benchmarks success"; else echo "build classic_benchmarks failed"; exit 1; fi

WORKDIR $BASE_DIR
COPY ./test $BASE_DIR/
RUN chmod +x $BASE_DIR/test.sh
