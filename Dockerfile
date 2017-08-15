# FROM mcchae/jdk8
#FROM mcchae/conda-jdk8
FROM mcchae/xfce
MAINTAINER MoonChang Chae mcchae@gmail.com
LABEL Description="alpine desktop env with conda (over xfce with novnc, xrdp and openssh server)"

################################################################################
# install openjdk8
################################################################################
RUN { \
        echo '#!/bin/sh'; \
        echo 'set -e'; \
        echo; \
        echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
    } > /usr/local/bin/docker-java-home \
    && chmod +x /usr/local/bin/docker-java-home
ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk
ENV PATH $PATH:/usr/lib/jvm/java-1.8-openjdk/jre/bin:/usr/lib/jvm/java-1.8-openjdk/bin

ENV JAVA_VERSION 8u131
ENV JAVA_ALPINE_VERSION 8.131.11-r2

RUN set -x \
    && apk add --no-cache \
        openjdk8="$JAVA_ALPINE_VERSION" \
    && [ "$JAVA_HOME" = "$(docker-java-home)" ]

################################################################################
# pycharm
################################################################################
WORKDIR /tmp
ENV PYCHARM_VER pycharm-community-2017.2
RUN wget https://download.jetbrains.com/python/$PYCHARM_VER.tar.gz \
    && tar xfz $PYCHARM_VER.tar.gz --exclude "jre64" \
    && rm -f $PYCHARM_VER.tar.gz \
    && mv $PYCHARM_VER /usr/local \
    && rm -f /usr/local/pycharm \
    && rm -rf /usr/local/$PYCHARM_VER/jre64 \
    && ln -s /usr/local/$PYCHARM_VER /usr/local/pycharm

WORKDIR /

################################################################################
# conda need glibc instead of musl libc
################################################################################
RUN apk --update  --repository http://dl-4.alpinelinux.org/alpine/edge/community add \
    bash \
    git \
    curl \
    ca-certificates \
    bzip2 \
    unzip \
    sudo \
    libstdc++ \
    glib \
    libxext \
    libxrender \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-2.25-r0.apk" -o /tmp/glibc.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-bin-2.25-r0.apk" -o /tmp/glibc-bin.apk \
    && curl -L "https://github.com/andyshinn/alpine-pkg-glibc/releases/download/2.25-r0/glibc-i18n-2.25-r0.apk" -o /tmp/glibc-i18n.apk \
    && apk add --allow-untrusted /tmp/glibc*.apk \
    && /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib \
    && /usr/glibc-compat/bin/localedef -i ko_KR -f UTF-8 ko_KR.UTF-8 \
    && rm -rf /tmp/glibc*apk /var/cache/apk/*

################################################################################
## package prepare for conda
################################################################################
#RUN apk add --no-cache --update \
#      bash \
#      build-base \
#      ca-certificates \
#      git \
#      bzip2-dev \
#      linux-headers \
#      ncurses-dev \
#      openssl \
#      openssl-dev \
#      readline-dev \
#      sqlite-dev \
#    && update-ca-certificates \
#    && rm -rf /var/cache/apk/*

# Configure environment
# above 4.0.5 has been failed in alpine
ENV CONDA_DIR=/opt/conda CONDA_VER=4.0.5
ENV PATH=$CONDA_DIR/bin:$PATH SHELL=/bin/bash LANG=C.UTF-8

################################################################################
# Install conda
################################################################################
# ENV LD_TRACE_LOADED_OBJECTS=1
RUN mkdir -p $CONDA_DIR \
    && echo export PATH=$CONDA_DIR/bin:'$PATH' > /etc/profile.d/conda.sh \
    && curl https://repo.continuum.io/miniconda/Miniconda3-${CONDA_VER}-Linux-x86_64.sh  -o mconda.sh \
    && /bin/bash mconda.sh -f -b -p $CONDA_DIR \
    && rm mconda.sh \
    && $CONDA_DIR/bin/conda install --yes conda==${CONDA_VER} \
    && sed -i -e "s|^export PATH=|export PATH=/opt/conda/bin:|g" /etc/profile

ADD chroot/usr /usr
