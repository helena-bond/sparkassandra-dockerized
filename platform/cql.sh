#!/usr/bin/env bash

docker run -it \
--net platform_default \
--link platform_cassandra_master_1:cassandra \
--rm cassandra:3.5 \
cqlsh cassandra

