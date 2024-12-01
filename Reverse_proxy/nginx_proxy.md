## The process is routingh traffic to private instance using nginx as reverse proxy
## On public machine where nginx is running 
## Modify the below content in the path
## We have to update the nginx config file in public ec2 instance
```
sudo vi /etc/nginx/sites-available/default
```
## The below process the acessing using public ip of the instance is where the nginx is running and the proxy set to the private ip of the instance where apache is running

```
server {
    listen 80;
    server_name 57.151.74.29; # Or your domain name, if any this is public ip 
    location / {
        proxy_pass http://10.0.0.4; #private ip of the instance where application is running
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
    }
}
```

## The below process is accessing the apache using the domain name the traffic will be routed from nginx server to apache server
## We have created a hosted zonee for the domain and created a A record for it
## By adding if section below server name we are not able to access the apache using public ip of the public instance 
```
server {
    listen 80;
    server_name ajaymaddela.online;
    if ($host = "57.151.74.29") {
        return 444;
    } # Or your domain name, public ip of nginx running 
    location / {
        proxy_pass http://10.0.0.4;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_redirect off;
    }
}
```


## On private where apache is running we have to make it listen 0.0.0.0:80
## Listen 80 to Listen 0.0.0.0:80