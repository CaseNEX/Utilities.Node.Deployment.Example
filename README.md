## Node Deployment Example

There is a golden image of this server already in amazon at AMI Name: `Utilities.Node.Deployment`

When starting a new node project, use the base image, then deploy code there.

The image has nginx, pm2, keymetrics, codedeploy-agent preinstalled

See CreateAMIFromScratch.md for the steps I took when creating the base image


## Making a new app

Restore the AMI to a new instance

Go to https://console.aws.amazon.com/ec2/v2/home?region=us-east-1 and click launch image
If this is production, we want 4 CPU's = c3.xlarge (same as skd.web), minimum 2 servers behind LB

Image Type: `Ubuntu 14.04 AMDx64`


