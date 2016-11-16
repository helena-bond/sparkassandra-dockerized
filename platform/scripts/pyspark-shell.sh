#!/usr/bin/env bash
export SPARK_LOCAL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`
cd /usr/local/spark
./bin/pyspark \
	--master spark://$(host spark_master | awk '/has address/ { print $4 }'):7077   \
	--conf spark.driver.host=${SPARK_LOCAL_IP} \
	--properties-file /spark-defaults.conf \
	--jars /spark-cassandra-connector-assembly-1.6.0-M2.jar\
	--conf spark.cassandra.connection.host=$(host cassandra_master | awk '/has address/ { print $4 }') \
	"$@"
