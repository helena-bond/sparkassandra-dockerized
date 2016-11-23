#!/usr/bin/env bash

node=$(kubectl get pods -l="app=cassandra" | grep cassandra | tail -1 | cut -d ' ' -f 1)
kubectl exec -ti $node  -- nodetool status

