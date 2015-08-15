There is a golden image of this server already in amazon at AMI Name: `Utilities.Node.Deployment`

The image has nginx, pm2, keymetrics, codedeploy-agent preinstalled

See CreateAMIFromScratch.md for the steps I took when creating the base image

The final goal is a golden image, which can be modified for any node app. The image will allow mulitple version of node, nginx, automatic code deployments, zero downtime restarts, performance monitoring and clustering. 

![https://blog.risingstack.com/content/images/2014/Oct/haproxy.png](https://blog.risingstack.com/content/images/2014/Oct/haproxy.png)

The code in this repo is simply a hello world express app, with the added data for aws CodeDeploy. 

## Using this image for your app

Here's my steps to create compass.web/dev


#### Restore the AMI to a new instance

Go to https://console.aws.amazon.com/ec2/v2/home?region=us-east-1 and click launch image

Choose the `Utilities.Node.Deployment.Example` AMI

If this is production, we want 4 CPU's = c3.xlarge (same as skd.web), minimum 2 servers behind LB

Image Type: `Ubuntu 14.04 AMDx64`

IAM role: `NODE_TEMP` NODE_TEMP gives the basic code deploy features, once we complete this box, we'll make a new golden image. The actual prod servers will have a new IAM role.

Auto Assign IP: `Enable`

8gb HDD is enough

Name: `new_compass-web-dev`

Security Group: `node-test` which  allows all access if you're on the VPN
use the `gsg-keypair`


Once the server boots, note the local ip address,
I save the details into `~/.ssh/config`
```
Host node
    HostName 10.0.1.163
    User ubuntu
    IdentityFile "~/Google Drive/Private Keys/gsg-keypair"
    IdentitiesOnly yes
```

### Install the code

After you ssh to the box, impersonate the www user
then download the code to the box

```
sudo su - www
cd /home/www/node/
git clone https://github.com/CaseNEX/Compass.Web.git
username: jlippold
password: createAToken
```

Since we use 2fa, create a personal access token from https://github.com/settings/tokens then delete it after you use it once.

Delete the .git directory: `rm -rf /home/www/node/Compass.Web/.git/`

### Build once and test


`npm install` 

!Compass may need postgres installed.

I need ports opened to redis, pg and redshift


Then I can run the server, like so:

`NODE_ENV=dev REDIS_URL=compass-staging.lyam42.0001.use1.cache.amazonaws.com REDIS_PORT=6379 REDIS_EXPIRE=120 PORT=3000 node server.js`







-- Freeze deps
