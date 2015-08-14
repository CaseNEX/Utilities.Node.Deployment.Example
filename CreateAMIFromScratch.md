## Create ami from scratch

Here are the steps I took to create the original AMI

### Create new AMI 

`Ubuntu 14.04 AMDx64`

Make sure to enable “Auto-assign Public IP"
Make sure you are on the VPN, from here on out

- Connect to box

For ease of access, edit `~/.ssh/config` and add:
```
Host node
    HostName 10.0.1.189
    User ubuntu
    IdentityFile "~/Google Drive/Private Keys/gsg-keypair"
    IdentitiesOnly yes
```
Then ssh to the box: `ssh node`

- Install git & build tools

```
sudo apt-get update
sudo apt-get install build-essential libssl-dev
sudo apt-get install git
```

- Install nginx

sudo apt-get update
sudo apt-get install nginx


_ configure nginx

`sudo vi /etc/nginx/sites-available/default `

This is a basic configuration, depending on product we may want nginx to handle: gzip encoding, static file serving, HTTP caching. This config simple proxies request on port 80 to port 300

```
server {
    listen 80;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
```

`sudo service nginx restart`

- Create non root user to run node

We want to give node the lowest privledges as possible on the box, so I am creating a `www` user, from which to run node

```
sudo useradd www
sudo mkdir /home/www
sudo usermod --home /home/www www
sudo chown www /home/www/
sudo chsh -s /bin/bash www #set default shell
```

- Login as New user

```
sudo su - www
mkdir /home/www/node
touch ~/.bashrc
```

- Edit the bash profile

`vi ~/.bashprofile`

Add the following line so nvm is auto initiated when you run as www: 

`source ~/.nvm/nvm.sh`


- install node via NVM https://github.com/creationix/nvm

Node version manager allows us to run multiple versions of node on the server. Read here for more info: https://github.com/creationix/nvm

```
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.25.4/install.sh | bash
## log out and log in, to see changes
exit
sudo su - www
## if no $ prompt, run bash
bash
## install node
nvm install 0.12.7
nvm use 0.12.7
node -v #should return 0.12.7
### make it default
nvm alias default 0.12.7
```
     
- install pm2

https://github.com/Unitech/pm2 is a process manager for node that enables clustering and analysis tools

Do the following as www user. All node projects will be in `/home/www/node`

```
npm install pm2 -g
cd /home/www/node/
git clone https://github.com/jlippold/HelloWorld.git
cd HelloWorld/
npm install
```

- verify app runs

`node index.js` then check http://10.0.1.189/ for hello world
port 80 is being proxied by nginx, 3000 is direct to nodejs

- setup logging directories for pm2

```
mkdir /home/www/logs/
mkdir /home/www/logs/HelloWorld/
```

- copy PM2 config file

When we are running prod apps, we remove HelloWorld, we edit this new processes.json to match our production deployed application

```
cp /home/www/node/HelloWorld/processes.json /home/www/node/processes.json

pm2 kill
pm2 start /home/www/node/processes.json
pm2 list #should return HelloWorld times the number of cpu's
```
verify app runs via pm2, check http://10.0.1.189/


- Generate StartUp Script, so app starts on reboot

we want to make sure PM2 starts the apps defined in `processes.json` on each boot

```
pm2 startup ubuntu
# should return
# [PM2] You have to run this command as root. Execute the following command:
# sudo su -c "env PATH=$PATH:/home/www/.nvm/versions/node/v0.12.7/bin pm2 startup ubuntu -u www"
# so go back to root account and run it
# `exit` to get back to ubuntu account
# now run it
ubuntu@ip-10-0-1-189:~$ sudo su -c "env PATH=$PATH:/home/www/.nvm/versions/node/v0.12.7/bin pm2 startup ubuntu -u www"
# now go back to www account
sudo su - www

# make sure server is running, if not start it
pm2 list 
pm2 start /home/www/node/processes.json

# now save it so it persists on reboot
pm2 save

# go back to root user and `sudo reboot`, check if pm2 list still shows the app
# check if is app is serving content http://10.0.1.189/
# script is in /etc/init.d/pm2-init.sh
# to start manually run `sudo /etc/init.d/pm2-init.sh start`
```

At the time of writing, this issue is open https://github.com/Unitech/PM2/issues/1321
So to patch this bug, you need to manually edit the generated `/etc/init.d/pm2-init.sh` file and replace `export PM2_HOME="/root/.pm2"` to point at the correct directory, which would be: `export PM2_HOME="/home/www/.pm2"`


if pm2 is acting up you can try:
```
pm2 delete all
pm2 kill
```
Then re-add the processes and save again

- Link with PM to keymetrics

`pm2 link PubKey SecretKey`

Get the keys from keymetrics website https://app.keymetrics.io/


- CodeDeploy

Spin up new instance
     Using image (`Node_Base_PM2` - `ami-d58923be`)
Choose an IAM Role with the policy (AWSCodeDeployRole) 
     My current Role Name = NODE_TEMP
Enable Auto Assign IP

You have to apply the role on instance create

Go to the NODE_TEMP role, and add an inline policy
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "cloudformation:*",
        "codedeploy:*",
        "ec2:*",
        "iam:AddRoleToInstanceProfile",       
        "iam:CreateInstanceProfile",
        "iam:CreateRole",
        "iam:DeleteInstanceProfile",
        "iam:DeleteRole",
        "iam:DeleteRolePolicy",
        "iam:GetRole",
        "iam:PassRole",
        "iam:PutRolePolicy",
        "iam:RemoveRoleFromInstanceProfile"
      ],
      "Resource": "*"
    }
  ]
}
```

add a second inline policy for s3
```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:Get*",
        "s3:List*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
```

ssh to new instance and install the agent:
http://docs.aws.amazon.com/codedeploy/latest/userguide/how-to-run-agent.html#how-to-run-agent-install-ubuntu

```
sudo apt-get update
sudo apt-get install awscli
sudo apt-get install ruby2.0
cd /home/ubuntu
sudo aws s3 cp s3://aws-codedeploy-us-east-1/latest/install . --region us-east-1
sudo chmod +x ./install
sudo ./install auto
```

- Create deployment in AWS

https://console.aws.amazon.com/codedeploy/home?region=us-east-1#/applications

Create new application

- Create new deployment group

App Name: `NODE_TEMP`
Tag Type: `Amazon EC2` - Key: `Name` - Value: `NODE_TEMP_CODEDEPLOY`
Default one at a time
`service role: arn:aws:iam::184281414649:role/CodeDeployServiceRole`


Add an app spec to the repo, like so: https://github.com/jlippold/HelloWorld/blob/master/appspec.yml
Add deploy scripts, like so: https://github.com/jlippold/HelloWorld/blob/master/deploy

- Create new deployment on AWS website http://s3.amazonaws.com/PicUp/30d2sF.png

- Choose create new deployment

Choose `My app is stored in github`
Repo Name format `CaseNEX\Whatever`

This has to be done atleast once, it grants amazon access to the github account


- Trigger CodeDeploy from VB.net webhooks

```
Dim codeConfig As New Amazon.CodeDeploy.AmazonCodeDeployConfig
codeConfig.RegionEndpoint = Amazon.RegionEndpoint.USEast1
Dim client As New Amazon.CodeDeploy.AmazonCodeDeployClient("SomeKey",  "SomeSecret", codeConfig)

Dim request As New Amazon.CodeDeploy.Model.CreateDeploymentRequest
request.ApplicationName = "NODE"
request.DeploymentGroupName = "NODE_TEMP"
request.Revision = New Amazon.CodeDeploy.Model.RevisionLocation
request.Revision.RevisionType = Amazon.CodeDeploy.RevisionLocationType.GitHub.ToString
request.Revision.GitHubLocation = New Amazon.CodeDeploy.Model.GitHubLocation

request.Revision.GitHubLocation.Repository = "jlippold/HelloWorld"
request.Revision.GitHubLocation.CommitId = "195be2bfe838fd7361cde32d1a568d16c261c44c"

Dim response As Amazon.CodeDeploy.Model.CreateDeploymentResponse = client.CreateDeployment(request)

If response.HttpStatusCode = 200 Then
	Console.WriteLine("SUCCESS")
End If
```

That code is to be integrated into webhooks, so on commit to the branch, we send the deploy.

- Misc code deploy stuff

We don't need to archive the code into s3, as code deploy normally wants. Using the GH integration is easier. 

Follow the logic as created in the deploy/*.sh files and modify to suit the project needs




