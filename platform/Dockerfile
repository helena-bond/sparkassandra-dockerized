FROM java:8

# install and configure supervisor, curl, net-tools, host
RUN apt-get update && apt-get install -y supervisor curl net-tools host && mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# download and install spark
#RUN curl -s https://www.apache.org/dist/spark/spark-1.6.2/spark-1.6.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
COPY scripts/spark-1.6.2-bin-hadoop2.6.zip /spark-1.6.2-bin-hadoop2.6.zip
RUN jar -xf spark-1.6.2-bin-hadoop2.6.zip /usr/local/
RUN cd /usr/local && ln -s spark-1.6.2-bin-hadoop2.6 spark

# copy some scripts to run spark
COPY scripts/start-master.sh /start-master.sh
COPY scripts/start-worker.sh /start-worker.sh
COPY scripts/spark-shell.sh /spark-shell.sh
COPY scripts/spark-submitJob.sh /spark-submitJob.sh
COPY scripts/spark-cassandra-connector-assembly-1.6.0-M2.jar /spark-cassandra-connector-assembly-1.6.0-M2.jar
COPY scripts/spark-defaults.conf /spark-defaults.conf

# Install Python & jupyter

# Install necessary packages
#RUN apt-get -y update && \
#    apt-get install -y --no-install-recommends python-qt4 && \
#    apt-get clean

# Create jovyan user with UID=1000 and in the 'users' group
ENV CONDA_DIR /opt/conda
ENV NB_UID 1000
ENV NB_USER sparkassandra
ENV HOME /home/$NB_USER
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR


#Use unprivileged user provided by base image
USER $NB_USER

# Setup jovyan home directory
RUN mkdir /home/$NB_USER/work && \
    mkdir /home/$NB_USER/.jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

# Install conda as jovyan
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.1.11-Linux-x86_64.sh && \
    echo "efd6a9362fc6b4085f599a881d20e57de628da8c1a898c08ec82874f3bad41bf *Miniconda3-4.1.11-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-4.1.11-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.1.11-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --quiet --yes conda==4.1.11 && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    $CONDA_DIR/bin/conda config --system --set auto_update_conda false && \
    conda clean -tipsy

# Install Python 2 packages and kernel spec
RUN conda create --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'ipython=3.2*' \
    'pandas' \
    'matplotlib' \
    'scipy' \
    'seaborn' \
    'scikit-learn' \
    && conda clean -yt

RUN $CONDA_DIR/envs/python2/bin/python \
    $CONDA_DIR/envs/python2/bin/ipython \
    kernelspec install-self --user

#Prepare environment
ENV PYSPARK_PYTHON=$CONDA_DIR/envs/python2/bin/python2.7
ENV PYSPARK_DRIVER_PYTHON=ipython
ENV PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser"

# Switch back to root so that supervisord runs under that user
USER root

#COPY and ADD don't add as the current user https://github.com/docker/docker/issues/7390, https://github.com/docker/docker/pull/13600
RUN chown sparkassandra:sparkassandra $HOME/work -R

COPY scripts/notebook.conf /etc/supervisor/conf.d/
#COPY scripts/pyspark-shell.sh /pyspark-shell.sh

# configure spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS=$SPARK_MASTER_OPTS
ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.9-src.zip

# install cassandra

# explicitly set user/group IDs
RUN groupadd -r cassandra --gid=999 && useradd -r -g cassandra --uid=999 cassandra

# grab gosu for easy step-down from root
ENV GOSU_VERSION 1.7
RUN set -x \
	&& apt-get update && apt-get install -y --no-install-recommends ca-certificates wget && rm -rf /var/lib/apt/lists/* \
	&& wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
	&& wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
	&& rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
	&& chmod +x /usr/local/bin/gosu \
	&& gosu nobody true \
	&& apt-get purge -y --auto-remove ca-certificates wget

RUN apt-key adv --keyserver ha.pool.sks-keyservers.net --recv-keys 514A2AD631A57A16DD0047EC749D6EEC0353B12C

RUN echo 'deb http://www.apache.org/dist/cassandra/debian 35x main' >> /etc/apt/sources.list.d/cassandra.list

ENV CASSANDRA_VERSION 3.5

RUN apt-get update \
	&& apt-get install -y cassandra="$CASSANDRA_VERSION" \
	&& rm -rf /var/lib/apt/lists/*

# https://issues.apache.org/jira/browse/CASSANDRA-11661
RUN sed -ri 's/^(JVM_PATCH_VERSION)=.*/\1=25/' /etc/cassandra/cassandra-env.sh

ENV CASSANDRA_CONFIG /etc/cassandra

COPY scripts/cassandra-configurator.sh /cassandra-configurator.sh
ENTRYPOINT ["/cassandra-configurator.sh"]

RUN mkdir -p /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chown -R cassandra:cassandra /var/lib/cassandra "$CASSANDRA_CONFIG" \
	&& chmod 777 /var/lib/cassandra "$CASSANDRA_CONFIG"
VOLUME /var/lib/cassandra

RUN mkdir -p /jobs
VOLUME /jobs

RUN mkdir -p /data
VOLUME /data

### Spark
# 4040: spark ui
# 7001: spark driver
# 7002: spark fileserver
# 7003: spark broadcast
# 7004: spark replClassServer
# 7005: spark blockManager
# 7006: spark executor
# 7077: spark master
# 8080: spark master ui
# 8081: spark worker ui
# 8888: spark worker
### Cassandra
# 7000: C* intra-node communication
# 7199: C* JMX
# 9042: C* CQL
# 9160: C* thrift service
### Jupyter
# 8888: Jupyter
EXPOSE 4040 7000 7001 7002 7003 7004 7005 7006 7077 7199 8080 8081 8888 9042 9160 8888
