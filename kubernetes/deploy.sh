#!/usr/bin/env bash

# create namespace
kubectl apply -f namespace-spark-cluster.yaml

# enter namespace

echo entering namespace

CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')
USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}')
CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}')
kubectl config set-context spark --namespace=spark-cluster --cluster=${CLUSTER_NAME} --user=${USER_NAME}
kubectl config use-context spark

# create spark master
kubectl apply -f spark-master-controller.yaml
kubectl apply -f spark-master-service.yaml

# create spark ui proxy
kubectl apply -f spark-ui-proxy-controller.yaml
kubectl apply -f spark-ui-proxy-service.yaml

# create spark workers
kubectl apply -f spark-worker-controller.yaml

# create pyspark
kubectl apply -f pyspark-controller.yaml
kubectl apply -f pyspark-service.yaml

# create cassandra cluster service
kubectl apply -f cassandra-service.yaml

# creates one instance per physical node
kubectl apply -f cassandra-daemonset.yaml


