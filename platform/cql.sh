#!/usr/bin/env bash

docker run -it \
--net platform_spark_cluster_nw \
--rm cassandra:3.9 \
cqlsh cassandra_master
