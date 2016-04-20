#!/bin/bash

# run a Spark master
docker run -d -t -P --name spark_master ekito/sparkassandra /start-master.sh

# run a Cassandra + Spark worker node
docker run -it --name worker1 --link spark_master:spark_master -d ekito/sparkassandra

# (optional) run some other nodes if you wish
docker run -it --name worker2 --link spark_master:spark_master --link worker1:cassandra -d ekito/sparkassandra