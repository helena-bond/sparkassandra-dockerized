#!/bin/bash

#Creates machines in default project previously initialized in gcloud

# recovers the default project id
PROJECT_ID="sparkassandrito"

# sets up google api credentials location
export GOOGLE_APPLICATION_CREDENTIALS="/home/francky/Share/DOCKER_SHARED/sparkassandrito-7cedd904e9fc.json"

# SET FIREWALL RULES
# auth
gcloud auth activate-service-account --key-file ~/Share/DOCKER_SHARED/sparkassandrito-7cedd904e9fc.json --project sparkassandrito

#Allow ssh, Swarm is able to talk to its instances
gcloud compute firewall-rules create default-ssh --allow tcp:22,icmp --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-swarm --allow tcp:2376,tcp:3376 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-consul --allow tcp:8500 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-spark --allow tcp:4040,tcp:6066,tcp:7000,tcp:7001,tcp:7002,tcp:7003,tcp:7004,tcp:7005,tcp:7006,tcp:7077,tcp:7199,tcp:8080,tcp:8081,tcp:8888,tcp:9042,tcp:9160  --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-cassandra --allow tcp:7199 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID

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
 docker-machine create \
  --driver google \
  --google-zone europe-west1-b \
  --google-project $PROJECT_ID \
  --swarm \
  --swarm-master \
  --swarm-discovery consul://$CONSUL_IP:8500 \
  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
  --engine-opt="cluster-advertise=eth0:2376" \
  gce-master-1

#create swarm node
# expose http8080 for spark master capabilities
for MGR_ID in {1..2}
do
  docker-machine create \
  --driver google \
  --google-zone europe-west1-b \
  --google-project $PROJECT_ID \
  --swarm \
  --swarm-discovery consul://$CONSUL_IP:8500 \
  --engine-opt cluster-store=consul://$CONSUL_IP:8500 \
  --engine-opt="cluster-advertise=eth0:2376" \
  --engine-label exposes=http8080 \
  --google-tags http8080 \
  gce-mgr-$MGR_ID
done
#list machines
docker-machine ls

#check swarm node ok
eval $(docker-machine env --swarm gce-master-1)

docker info

#TO TRY
#docker run swarm list consul://$(docker-machine ip consul-machine):8500



