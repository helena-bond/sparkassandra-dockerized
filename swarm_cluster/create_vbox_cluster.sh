#!/bin/bash

################################## INSTRUCTIONS ##################################
# 1. Install docker-machine                                                      #
# 2. Install gcloud CLI                                                          #
##################################################################################

#Creates machines in default project previously initialized in gcloud

# Clean any existing machines
yes | docker-machine rm local -y -f
yes | docker-machine rm swarm-manager -y -f
yes | docker-machine rm node-01 -y -f

# Create machine (kv store)
docker-machine create --driver virtualbox local

# Get SWARM token
eval $(docker-machine env local)
SWARM_CLUSTER_TOKEN="$(docker run --rm swarm create)"

# Build swarm-manager
docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery token://$SWARM_CLUSTER_TOKEN \
    swarm-manager

# Build node-01
docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$SWARM_CLUSTER_TOKEN \
    node-01

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