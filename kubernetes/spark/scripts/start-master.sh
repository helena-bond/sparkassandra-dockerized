#!/usr/bin/env bash
unset SPARK_MASTER_PORT
export SPARK_LOCAL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

/usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master \
--ip spark-master -i $SPARK_LOCAL_IP  --port 7077 --webui-port 8080