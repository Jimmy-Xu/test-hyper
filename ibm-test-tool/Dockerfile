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

############################################################
# install common packages
############################################################
#install add-apt-repository
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y clean && \
    apt-get -y update

RUN apt-get install -y software-properties-common
RUN apt-get install -y python-software-properties
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get -y update
RUN apt-get -y install gcc-4.9 g++-4.9
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 60 --slave /usr/bin/g++ g++ /usr/bin/g++-4.9
RUN apt-get -y install git make automake libc6-dev libtool dos2unix
RUN apt-get -y install libgomp1 numactl

############################################################
# compile sysbench from source
############################################################
WORKDIR $BASE_DIR
RUN git clone https://github.com/Jimmy-Xu/STREAM.git
WORKDIR ${BASE_DIR}/STREAM
RUN git checkout mine
RUN make stream_c.exe
RUN if [ -f stream_c.exe ];then echo "build stream success"; else echo "build stream failed"; exit 1; fi
