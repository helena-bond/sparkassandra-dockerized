#!/usr/bin/env bash

docker run -it \
--net sparkassandradockerized_default \
--link sparkassandradockerized_cassandra_master_1:cassandra \
--rm cassandra \
cqlsh cassandra