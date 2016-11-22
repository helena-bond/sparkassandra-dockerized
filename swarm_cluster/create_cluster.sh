#!/bin/bash

# recovers the default project id
PROJECT_ID="sparkassandrito"
MASTER_COUNT=1
NODE_COUNT=3

#CREATE KEY-VALUE STORE FOR DISCOVERY
#create consul kv store
docker-machine create \
--driver google \
--google-zone europe-west1-b \
--google-project $PROJECT_ID \
gce-consul-1

#redirect docker-ci on consul machine to deploy consul image
eval $(docker-machine env gce-consul-1)

#deploy consul image
docker run -d -p 8500:8500 \
--restart always --name=consul \
progrium/consul -server -bootstrap

CONSUL_IP=$(docker-machine ip gce-consul-1)

echo Consul Server up and running. IP: $CONSUL_IP

#create swarm cluster relying on CONSUL discovery

#create swarm master

for ((ID = 1; ID <= $MASTER_COUNT; ID++));
do
 docker-machine create \
  --driver google \
  --google-zone europe-west1-b \
  --google-disk-type "pd-standard" \
  --google-project $PROJECT_ID \
  --swarm \
  --swarm-master \
  --swarm-discovery consul://$CONSUL_IP:8500 \
  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
  --engine-opt="cluster-advertise=eth0:2376" \
  gce-master-$ID &
done

#create swarm node
# expose http8080 for spark master capabilities
for ((ID = 1; ID <= $NODE_COUNT; ID++));
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
  gce-node-$ID &
done

wait

# Add nodes to instance group for reverse proxy and load balancing
for ((ID = 1; ID <= $MASTER_COUNT; ID++));
do
 gcloud compute instance-groups unmanaged add-instances sparkcluster --instances gce-master-$ID --zone europe-west1-b
done

for ((ID = 1; ID <= $NODE_COUNT; ID++));
do
 gcloud compute instance-groups unmanaged add-instances sparkcluster --instances gce-node-$ID --zone europe-west1-b
done

#Some checks

#list machines
docker-machine ls

#check swarm node ok
eval $(docker-machine env --swarm gce-master-1)

docker info