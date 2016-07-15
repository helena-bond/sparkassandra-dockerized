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

docker run \
-it --net platform_default \
-v jobs:/jobs \
platform_spark_master \
./spark-submitJob.sh --job $JOB --class $CLASS --args $ARGUMENTS