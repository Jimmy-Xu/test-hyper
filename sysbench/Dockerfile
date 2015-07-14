FROM ubuntu:14.04
MAINTAINER xjimmy@mc2.io

ENV BASE_DIR /root
ENV PATH=/usr/local/bin:$PATH


# backup old sources.list
RUN cp /etc/apt/sources.list /etc/apt/sources.list.bak

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
RUN apt-get -y install bzr make automake libc-dev  libtool dos2unix

############################################################
# compile sysbench from source
############################################################
WORKDIR $BASE_DIR
RUN bzr branch lp:~sysbench-developers/sysbench/0.5  sysbench-0.5
WORKDIR sysbench-0.5
RUN ./autogen.sh
RUN ./configure --without-mysql
RUN make
RUN make install

COPY ./test $BASE_DIR/test
WORKDIR $BASE_DIR

CMD sysbench --version

