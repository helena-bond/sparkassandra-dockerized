# Copyright (c) Jupyter Development Team.
# Distributed under the terms of the Modified BSD License.
FROM jupyter/scipy-notebook

MAINTAINER ekito

USER root

# Spark dependencies
ENV APACHE_SPARK_VERSION 1.6.2
RUN apt-get -y update && \
    apt-get install -y --no-install-recommends openjdk-7-jre-headless curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN cd /tmp

RUN curl -s https://www.apache.org/dist/spark/spark-1.6.2/spark-1.6.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.2-bin-hadoop2.6 spark

# Mesos dependencies
# Currently, Mesos is not available from Debian Jessie.
# So, we are installing it from Debian Wheezy. Once it
# becomes available for Debian Jessie. We should switch
# over to using that instead.
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
    DISTRO=debian && \
    CODENAME=wheezy && \
    echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y --force-yes install mesos=0.22.1-1.0.debian78 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Spark and Mesos config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

USER $NB_USER
