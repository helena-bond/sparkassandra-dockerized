#!/bin/bash

#Creates machines in default project previously initialized in gcloud

if [ "$#" -ne 1 ]; then
   echo "Illegal number of parameters"
   exit 1
fi
# recovers the default project id
PROJECT_ID="sparkassandrito"

# sets up google api credentials location
export GOOGLE_APPLICATION_CREDENTIALS="/home/francky/Share/DOCKER_SHARED/sparkassandrito-7cedd904e9fc.json"

docker-machine rm $1-consul-1 -y -f

for MGR_ID in {1..4}
do
	docker-machine rm $1-node-$MGR_ID -y -f
done

docker-machine rm $1-master-1 -y -f

docker-machine ls

