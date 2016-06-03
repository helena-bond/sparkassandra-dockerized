#!/bin/bash
docker stop local-cassandra
docker rm local-cassandra
docker run --name local-cassandra -d -p 9042:9042 cassandra:3.5