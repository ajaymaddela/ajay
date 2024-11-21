## To run the container on the ECS ensure docker is installed

## Also install ecs agent on the instance and check the agent status is running.

## Download the rpm packages for amazon linux using below command.

```
curl -O https://s3.us-west-2.amazonaws.com/amazon-ecs-agent-us-west-2/amazon-ecs-init-latest.x86_64.rpm
sudo yum localinstall -y amazon-ecs-init-latest.x86_64.rpm
```

## Dowmload the Deb packages 

```
curl -O https://s3.us-west-2.amazonaws.com/amazon-ecs-agent-us-west-2/amazon-ecs-init-latest.amd64.deb
sudo dpkg -i amazon-ecs-init-latest.amd64.deb
```
## Edit the /lib/systemd/system/ecs.service file and add the following line at the end of the [Unit] section.

```
After=cloud-final.service
```

## To register the instance with a cluster other than the default cluster, edit the /etc/ecs/ecs.config file and add the following contents. The following example specifies the MyCluster cluster.

```
ECS_CLUSTER=MyCluster
```

## sudo systemctl start ecs
## sudo systemctl enable ecs
## sudo systemctl status ecs