#!/bin/bash

yes | docker-machine rm vbox-consul-1 -y -f
for MGR_ID in {1..3}
do
    yes | docker-machine rm vbox-mgr-$MGR_ID -y -f
done

#Creates machines in default project previously initialized in gcloud

#create consul kv store
docker-machine create --driver virtualbox vbox-consul-1

eval $(docker-machine env vbox-consul-1)

docker run -d -p 8500:8500 \
--restart always --name=consul \
progrium/consul -server -bootstrap

CONSUL_IP=$(docker-machine ip vbox-consul-1)

echo Consul Server up and running. IP: $CONSUL_IP

#create swarm managers
for MGR_ID in {1..3}
do
  docker-machine create \
  --driver virtualbox \
  --swarm \
  --swarm-master \
  --swarm-discovery consul://$CONSUL_IP:8500 \
  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
  --engine-opt cluster-advertise=eth1:2376 \
  vbox-mgr-$MGR_ID
done

eval $(docker-machine env --swarm vbox-mgr-1)

cd ../platform

docker-compose up -d

#for NODE_ID in {1..1}
#do
#  docker-machine create \
#  --driver virtualbox \
#  --swarm \
#  --swarm-discovery consul://$CONSUL_IP:8500 \
#  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
#  --engine-opt cluster-advertise=eth1:2376 \
#  vbox-node-$NODE_ID
#done