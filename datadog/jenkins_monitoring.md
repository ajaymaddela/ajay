```
Install datadog agent on instance where jenkins is running 
Go to jenkins 
In manage jenkins download plugin datadog
After restart the jenkins
Go to manage jenkins and configure system 
Go to datadog section there is a recommended process Use the Datadog Agent to report to Datadog (recommended)  instead of api key
Enable port 8125 in the security group of the instance and enable log collection and ci visibilty
Then save the configuration.

Go to datadog
Then integration and search for jenkins
Then select configure and place the server url means ip of the instance where accessing jenkins
After five minutes go to datadog dashboard and jenkins overview and all data is viewed there.
```