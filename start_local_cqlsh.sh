#!/bin/bash
docker run -it --link local-cassandra:cassandra --rm cassandra cqlsh cassandra