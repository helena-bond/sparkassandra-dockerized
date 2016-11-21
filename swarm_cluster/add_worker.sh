#!/bin/bash

# recovers the default project id
PROJECT_ID="sparkassandrito"

# sets up google api credentials location
export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/sparkassandrito-7cedd904e9fc.json"



#redirect docker-ci on consul machine to deploy consul image
eval $(docker-machine env gce-consul-1)




#create swarm node
# expose http8080 for spark master capabilities
for MGR_ID in {4..5}
do
  docker-machine create \
  --driver google \
  --google-zone europe-west1-b \
  --google-project $PROJECT_ID \
  --swarm \
  --swarm-discovery consul://$CONSUL_IP:8500 \
  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
  --engine-opt="cluster-advertise=eth0:2376" \
  --engine-label sparkport=http8080 \
  --engine-label jupyterport=http8890 \
  --google-tags http8080,http8890 \
  gce-node-$MGR_ID &
done


wait

#list machines
docker-machine ls

#check swarm node ok
eval $(docker-machine env --swarm gce-master-1)

docker info

#TO TRY
#docker run swarm list consul://$(docker-machine ip consul-machine):8500



