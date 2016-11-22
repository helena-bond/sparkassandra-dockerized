#!/bin/bash

#Creates machines in default project previously initialized in gcloud
# recovers the default project id
PROJECT_ID="sparkassandrito"

docker-machine rm gce-consul-1 -y -f &

for MGR_ID in {1..4}
do
	docker-machine rm gce-node-$MGR_ID -y -f &
done

docker-machine rm gce-master-1 -y -f &

wait

docker-machine ls

