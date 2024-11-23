## On amazon linux installing httpd

## Ensure the ec2 instance had sufficient permissions

```
sudo yum install httpd -y
```

```
sudo systemctl start httpd
```

```
sudo systemctl enable httpd
```

```
sudo vi /etc/httpd/conf/httpd.conf
```

```
LogLevel warn
CustomLog /var/log/httpd/access_log combined
ErrorLog /var/log/httpd/error_log
```

```
sudo systemctl restart httpd
```

## check the permissions
```
sudo mkdir -p /var/log/httpd
sudo chown apache:apache /var/log/httpd
sudo chmod 755 /var/log/httpd
```




```
sudo yum install amazon-cloudwatch-agent
```











```
sudo vi /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

```
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/httpd/access_log",
            "log_group_name": "httpd-access-logs",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%d/%b/%Y:%H:%M:%S %z"
          },
          {
            "file_path": "/var/log/httpd/error_log",
            "log_group_name": "httpd-error-logs",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%a %b %d %H:%M:%S.%f %Y"
          }
        ]
      }
    }
  }
}
```

```
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

## Restart the cloud watch agent
```
sudo systemctl restart amazon-cloudwatch-agent
```

```
sudo systemctl status amazon-cloudwatch-agent
```

```
it will automatically creates two log groups
```