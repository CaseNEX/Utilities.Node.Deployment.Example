There is a golden image of this server already in amazon at AMI Name: `Utilities.Node.Deployment`

The image has nginx, pm2, keymetrics, codedeploy-agent preinstalled

See CreateAMIFromScratch.md for the steps I took when creating the base image

The final goal is a golden image, which can be modified for any node app. The image will allow mulitple version of node, nginx, automatic code deployments, zero downtime restarts, performance monitoring and clustering. 

![https://blog.risingstack.com/content/images/2014/Oct/haproxy.png](https://blog.risingstack.com/content/images/2014/Oct/haproxy.png)

The code in this repo is simply a hello world express app, with the added data for aws CodeDeploy. 

## Using this image for your app

Restore the AMI to a new instance

Go to https://console.aws.amazon.com/ec2/v2/home?region=us-east-1 and click launch image
If this is production, we want 4 CPU's = c3.xlarge (same as skd.web), minimum 2 servers behind LB

Image Type: `Ubuntu 14.04 AMDx64`


