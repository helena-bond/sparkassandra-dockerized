FROM java:8

# install and configure supervisor, curl, net-tools, host
RUN apt-get update && apt-get install -y curl net-tools host

# download and install spark
RUN curl -s https://www.apache.org/dist/spark/spark-1.6.2/spark-1.6.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.6.2-bin-hadoop2.6 spark

# copy some scripts to run spark
COPY scripts/start-master.sh /start-master.sh
COPY scripts/start-worker.sh /start-worker.sh
COPY scripts/spark-shell.sh /spark-shell.sh
COPY scripts/spark-submitJob.sh /spark-submitJob.sh
COPY scripts/spark-cassandra-connector-assembly-1.6.0-M2.jar /spark-cassandra-connector-assembly-1.6.0-M2.jar
COPY scripts/spark-defaults.conf /spark-defaults.conf

RUN mkdir -p /jobs
VOLUME /jobs

# configure spark
ENV SPARK_HOME /usr/local/spark
ENV SPARK_MASTER_OPTS="-Dspark.driver.port=7001 -Dspark.fileserver.port=7002 -Dspark.broadcast.port=7003 -Dspark.replClassServer.port=7004 -Dspark.blockManager.port=7005 -Dspark.executor.port=7006 -Dspark.ui.port=4040 -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_OPTS=$SPARK_MASTER_OPTS
ENV SPARK_MASTER_PORT 7077
ENV SPARK_MASTER_WEBUI_PORT 8080
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081

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

EXPOSE 4040 7001 7002 7003 7004 7005 7006 7077 8080 8081 8888
