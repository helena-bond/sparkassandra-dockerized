#!/usr/bin/env bash
cd /usr/local/spark
export SPARK_LOCAL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
export SPARK_MASTER=`host spark_master | awk '/has address/ { print $4 }'`
./bin/spark-class org.apache.spark.deploy.worker.Worker \
	spark://$SPARK_MASTER:7077 \
	--properties-file /spark-defaults.conf \
	-i $SPARK_LOCAL_IP \
	"$@"
