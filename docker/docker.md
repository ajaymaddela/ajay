
- To create docker container with ram
```
docker container run --name jenkins -d -P jenkins
```
# check logs 
- docker container logs jenkins

- `run with memory`
```
docker container run --name r-mem-jenkins -P -d --memory 512m jenkins
docker container run --name jenkins -P -d jenkins
```
- run with cpu
```
docker container run --name r-memcpu-jenkins -P -d --cpus="1" --memory 512m jenkins
docker container run --name jenkins -P -d jenkins
```
