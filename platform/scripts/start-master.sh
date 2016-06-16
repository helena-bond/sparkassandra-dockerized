#!/usr/bin/env bash
export SPARK_MASTER_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
export SPARK_LOCAL_IP=$SPARK_MASTER_IP

/usr/local/spark/bin/spark-class org.apache.spark.deploy.master.Master \
--properties-file /spark-defaults.conf --ip SPARK_MASTER_IP -i $SPARK_LOCAL_IP "$@"