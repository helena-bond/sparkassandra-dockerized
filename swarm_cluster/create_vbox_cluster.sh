#!/bin/bash

################################## INSTRUCTIONS ##################################
# 1. Install docker-machine                                                      #
# 2. Install gcloud CLI                                                          #
##################################################################################

#Creates machines in default project previously initialized in gcloud

# Clean any existing machines
yes | docker-machine rm vbox-consul -y -f
yes | docker-machine rm swarm-manager -y -f
for MGR_ID in {1..3}
do
    yes | docker-machine rm node-$MGR_ID -y -f
done

# Create machine consul (kv store)
docker-machine create --driver virtualbox vbox-consul

eval $(docker-machine env vbox-consul)

docker run -d -p 8500:8500 \
--restart always --name=consul \
progrium/consul -server -bootstrap

# Get IP
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



#
#docker run -d -p 8500:8500 \
#--restart always --name=consul \
#progrium/consul -server -bootstrap
#
#CONSUL_IP=$(docker-machine ip vbox-consul-1)
#
#echo Consul Server up and running. IP: $CONSUL_IP
#
##create swarm managers
#for MGR_ID in {1..3}
#do
#  docker-machine create \
#  --driver virtualbox \
#  --swarm \
#  --swarm-master \
#  --swarm-discovery consul://$CONSUL_IP:8500 \
#  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
#  --engine-opt cluster-advertise=eth1:2376 \
#  vbox-mgr-$MGR_ID
#done