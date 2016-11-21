#!/bin/bash

# recovers the default project id
PROJECT_ID="sparkassandrito"

# sets up google api credentials location
export GOOGLE_APPLICATION_CREDENTIALS="sparkassandrito-7cedd904e9fc.json"

# SET FIREWALL RULES
# auth
gcloud auth activate-service-account --key-file sparkassandrito-7cedd904e9fc.json --project sparkassandrito

#Allow ssh, Swarm is able to talk to its instances
gcloud compute firewall-rules create default-ssh --allow tcp:22,icmp --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-swarm --allow tcp:2376,tcp:3376 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-consul --allow tcp:8500 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-spark --allow tcp:4040,tcp:6066,tcp:7000,tcp:7001,tcp:7002,tcp:7003,tcp:7004,tcp:7005,tcp:7006,tcp:7077,tcp:7199,tcp:8080,tcp:8081,tcp:8888,tcp:9042,tcp:9160  --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-cassandra --allow tcp:7199 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID
gcloud compute firewall-rules create default-jupytherUI --allow tcp:8890 --source-ranges 0.0.0.0/0 --project=$PROJECT_ID

#