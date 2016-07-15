#!/usr/bin/env bash
gradle fatJar

./platform/submitJob.sh --job sparkassandra-all.jar --class io.ekito.sparktest.IngestionJob --args /data/1987.csv