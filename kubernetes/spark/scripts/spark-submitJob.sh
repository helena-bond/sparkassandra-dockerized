#!/usr/bin/env bash

while [[ $# -gt 1 ]]
do
key="$1"

case $key in
    -j|--job)
    JOB="$2"
    shift # past argument
    ;;
    -c|--class)
    CLASS="$2"
    shift # past argument
    ;;
    -a|--args)
    ARGUMENTS="$2"
    shift # past argument
    ;;
    --default)
    DEFAULT=YES
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done
echo JOB       = "${JOB}"
echo CLASS     = "${CLASS}"
echo ARGUMENTS = "${ARGUMENTS}"

/usr/local/spark/bin/spark-submit \
--class $CLASS \
--master spark://$(host spark_master | awk '/has address/ { print $4 }'):7077 \
--deploy-mode cluster \
/jobs/$JOB $ARGUMENTS