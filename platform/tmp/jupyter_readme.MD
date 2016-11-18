#SET UP JUPYTER CONTAINER
Startint from this container 
```
https://github.com/jupyter/docker-stacks/tree/master/pyspark-notebook
```





#ACCESS EXTERNAL DATA
Mount external directory to container. See -v
```
docker run -v /home/francky:/home/francky -d -p 8888:8888 jupyter/pyspark-notebook
```
##Work with those mounted volume
```
docker exec ${IMAGE-ID} bash
```

You could then, after promt : 
```
cp *.csv* /home/jovyan/work
```


#PYTHON JUPYTER COMMANDS

##Use python2
```
# make sure the driver and workers all use Python2
import os
os.environ['PYSPARK_PYTHON'] = '/opt/conda/envs/python2/bin/python'
import pyspark
sc = pyspark.SparkContext('local[*]')

# do something to prove it works
rdd = sc.parallelize(range(1000))
rdd.takeSample(False, 5)
```