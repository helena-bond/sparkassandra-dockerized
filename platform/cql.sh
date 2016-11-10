#!/usr/bin/env bash

docker run -it \
--net platform_back-tier \
--rm cassandra:3.5 \
cqlsh cassandra_master