FROM mcchae/xfce
MAINTAINER MoonChang Chae mcchae@gmail.com
LABEL Description="alpine desktop env with ide (over xfce with novnc, xrdp and openssh server)"

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

ADD chroot/usr /usr

