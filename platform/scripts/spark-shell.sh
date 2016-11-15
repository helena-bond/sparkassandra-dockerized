#!/usr/bin/env bash

export SPARK_LOCAL_IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

echo SPARK_LOCAL_IP is : $SPARK_LOCAL_IP

echo spark url is  : $(host platform_spark_master_1 | awk '/has address/ { print $4 }')

cd /usr/local/spark
./bin/spark-shell \
	--master spark://$(host platform_spark_master_1 | awk '/has address/ { print $4 }'):7077   \
	--conf spark.driver.host=${SPARK_LOCAL_IP} \
	--properties-file /spark-defaults.conf \
	--jars /spark-cassandra-connector-assembly-1.6.0-M2.jar\
	--conf spark.cassandra.connection.host=$(host platform_cassandra_master_1 | awk '/has address/ { print $4 }') \
	"$@"
