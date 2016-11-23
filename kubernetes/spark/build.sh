#!/usr/bin/env bash

imageId=spark
projectId=swarm-test-147711

docker build -t ekito/$imageId .
docker tag ekito/$imageId gcr.io/$projectId/$imageId
gcloud docker -- push gcr.io/$projectId/$imageId