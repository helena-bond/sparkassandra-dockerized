#!/usr/bin/env bash

docker run \
-it --net platform_default \
-v $(pwd)/../build/libs:/jobs \
platform_spark_master \
./spark-submitJob.sh --job sparkassandra-all.jar --class io.ekito.sparktest.IngestionJob --args /data/1987.csv