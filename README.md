
﻿# Auto Deploy in AWS EC2 using GitHub Actions and CodeDeploy

## Prerequisites

 - Having an **AWS** account
 - Having a **GitHub** account
 - Having **NodeJS**, **npm** and **express-generator** installed on your machine

## Index 

1. Create a GitHub repo
2. Set up AWS IAM for EC2 instance
3. Set up AWS IAM for CodeDeploy
4. Create EC2 instance
5. Access the EC2 instance via SSH
6. Create EC2 application
7. Create deployment group
8. Generate boilerplate in your GitHub repo (express-generator)
9. Set up AWS IAM user
10. Test the deployment
11. Create GitHub Actions
12. Verify the automated deployment was successful

## 1. Create a GitHub repo 

-   Go to your GitHub profile, and then click on "**Repositories**". Click on the green button "**New**", give the repo a name (***ec2-code-deploy***) and then choose Public or Private based on your needs; then click on the "**Create repository**" green button. Once you have created it, copy the link, go to your terminal and enter the command: `git clone [link-to-your-repo.git]`.

## 2. Set up AWS IAM role for EC2 instance

 - In your AWS account, go to the **IAM control panel**, in the section **Roles**: https://console.aws.amazon.com/iam/home#/roles
 - Create a new role:
	 - click on "**Create role**" button
	 - be sure that the "**AWS service**" is setted, and under "Common use cases" select "**EC2**". Then click on "**Next: Permissions**". 
	 - in the Search box find the following policy:
		 - **AmazonEC2RoleforAWSCodeDeploy**
	 - click on "**Next: Tags**", and then on "**Next: Review**". Give a name to the role (***ec2-role***) and then click on "**Create role**". 
	 - Open the role you just created, and switch to the "**Trust relationships**" panel; click on "**Edit trust relationship**" and paste the following:
  ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
```
  
## 3. Set up AWS IAM role for CodeDeploy

- In your AWS account, go to the **IAM control panel**, in the section **Roles**: https://console.aws.amazon.com/iam/home#/roles
 - Create a new role:
	 - click on "**Create role**" button
	 - be sure that the "**AWS service**" is setted, and under "Common use cases" select "**EC2**". Then click on "**Next: Permissions**".
	 - in the Search box find the following policies:
		 - **AdministratorAccess**
		 - **AmazonEC2FullAccess**
		 - **AWSCodeDeployFullAccess**
		 - **AWSCodeDeployRole**
	 - click on "**Next: Tags**", and then on "**Next: Review**". Give a name to the role (***CodeDeploy_Role***) and then click on "**Create role**". 
	 - Open the role you just created, and switch to the "**Trust relationships**" panel; click on "**Edit trust relationship**" and paste the following:
  ```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "codedeploy.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
  ```

## 4. Create EC2 instance

 - In your AWS account, go to the **EC2 control panel**, in the section **Roles**: https://console.aws.amazon.com/ec2/v2/home
 - Click on "**Launch instance**" and find "**Ubuntu Server 20.04 LTS (HVM), SSD Volume Type**", and be sure that "**64-bit (x86)**" is selected. After that, click on "**Select**".
 - Keep "**t2.micro**" selected, and click on "**Next: Configure Instance Details**".
 - In "**IAM role**", select the role for EC2 we created before (in this example, the name is "***ec2-role***"). Then click on "**Next: Add Storage**".
 - Click on "**Next: Add Tags**", then click on "**Add Tag**". On the "**Key**" field, write a tag key (***development***). Then click on "**Next: Configure Security Group**".
 - Click on "**Add rule**". Edit this new rule as the following:
	 - on the "**Type**" field, select "**All traffic**";
	 - on the "**Source**" field, select "**Anywhere**".
 - Click on "**Review and Launch**".
 - Check if everything's ok, then click on "**Launch**".
 - Select "**Create a new key pair**", then give it a name (***ec2-key-pair***). Then click on "**Download Key Pair**". Then click on "**Launch Instances**".
 - Once the instance is running, **right-click on *instance-id*** and click on "**Connect**".
 - **Take note of the public IP and the User name** (if you selected Ubuntu, then the User name should be ***ubuntu***).

## 5. Access the EC2 instance via SSH

 - On your machine, **open the terminal** in the folder where you downloaded the key pair, and **enter the following commands** (supposing you named the key pair as suggested in this tutorial):
	 - `chmod 400 ec2-key-pair.pem`
	 - `ssh -i ./ec2-key-pair.pem ubuntu@[public-IP]`
 - **Once you're in**, run the following commands:
	 - `sudo apt update`
	 - `sudo apt install -y ruby`
 - Go to [CodeDeploy resource kit reference](https://docs.aws.amazon.com/codedeploy/latest/userguide/resource-kit.html#resource-kit-bucket-names): based on your region, take note of "**Bucket-name replacement**" and "**Region identifier**". In this example, I will use respectively "***aws-codedeploy-eu-central-1***" and "***eu-central-1***".
 - Enter the following command:
	 - `wget https://aws-codedeploy-eu-central-1.s3.eu-central-1.amazonaws.com/latest/install`
	 - `sudo chmod +x ./install`
	 - `sudo ./install auto`
	 - `sudo service codedeploy-agent start`

## 6. Create EC2 application

 - In your AWS account, go to the **CodeDeploy control panel**, in the section **Applications**: https://console.aws.amazon.com/codesuite/codedeploy/applications
 - **Be sure that you're on the correct region**. On the top-right corner, to the right of your username, click to select the correct region.
 - Click on "**Create application**", then give it a name (***Git_Application***).
 - In the "Compute Platform", select "**EC2/On-premises**".
 - Click on "**Create application**".

## 7. Create deployment group

 - Once the application is created, you should be in the application page. Click on "**Create deployment group**".
 - Give the deployment group a name (***development_group***).
 - You need to copy the ARN of the ***CodeDeploy_Role*** you created in step 3. To do so:
	 - In your AWS account, go to the **IAM control panel**, in the section **Roles**: https://console.aws.amazon.com/iam/home#/roles
	 - Click on the **CodeDeploy_Role**;
	 - Copy the **Role ARN**, which should be like this: `arn:aws:iam::************:role/CodeDeploy_Role`
 - **Return to the development group creation page**. In the "**Service role**" section, **paste the Role ARN** you copied.
 - In the "**Deployment type**" section, be sure that **In-place** is selected.
 - In the "**Environment configuration**" section, select **Amazon EC2 instances**. On the Key field, paste the Key you created in step 4 (***development***). 
 - In the "**Deployment settings**" section, select CodeDeployDefault.**OneAtATime**.
 - In the section "**Load balancer**", be sure that **Enable load balancing** is **NOT** selected.
 - Click on "**Create deployment group**".

## 8. Generate boilerplate in your GitHub repo using express-generator

 - In the folder of the project you clonated in the step 1, run the follow commands:
 - `express ; npm install`
 - Create a file `appspec.yml` containing the following:
```yml
version: 0.0
os: linux

files:
  - source: .
    destination: /home/ubuntu

hooks:
  BeforeInstall:
   - location: before-install.sh
     timeout: 300
     runas: root
  AfterInstall:
   - location: after-install.sh
     timeout: 300
     runas: root
  ApplicationStart:
   - location: application-start.sh
     timeout: 300
     runas: root
```

 - Create a file `before-install.sh` containing the following:
```shell
apt -y update

curl --silent --location https://rpm.nodesource.com/setup_4.x | bash -
apt -y install nodejs
apt -y install npm
npm install -g pm2
pm2 update
```

 - Create a file `after-install.sh` containing the following:
```shell
cd /home/ubuntu
npm install
```

 - Create a file `application-start.sh` containing the following:
```shell
cd /home/ubuntu
pm2 start ./bin/www -n www -f
```

 - **Commit and push** your changes to create a first commit. You'll need it's hash in next steps.

## 9. Set up AWS IAM user

-   In your AWS account, go to the **IAM control panel**, in the section **Users**: https://console.aws.amazon.com/iam/home#/users
    
-   Create a new user:
    -   click on "**Add user**" button, then give the user a name (***ec2-user***) and, under the "Select AWS access type" section, check the "**Programmatic access**" box; then, click on "**Next: Permissions**"
    -   In "Set permissions" section, be sure that the "**Add user to group**" is setted, and then click "**Create group**". Give the group a name (***ec2-group***), and in the Search box find the following policy:
        -   **AWSCodeDeployFullAccess**


    -   Then click on "**Next: Tags**" and then on "**Next: Review**". Be sure that everything's ok and then click on "**Create user**".
    -   **IMPORTANT**: now you'll see the ***Access key ID*** and the ***Secret access key*** for the User you just created. We need to set them as GitHub Secrets. Don't close this window until the next steps aren't completed, or you'll lose these credentials forever, making it necessary to repeat the entire User creation procedure.
        -   In your GitHub repo, go to the "**Settings**" panel, then go to "**Secrets**";
        -   Click on "**New repository secret**": give the secret a name (`AWS_ACCESS_KEY_ID`) and paste the value you see in the AWS User page. Then click on "**Add Secret**";
        -   Do the same for the Secret access key: give it a name (`AWS_SECRET_ACCESS_KEY`), paste the value and then "**Add Secret**".

## 10. Test the deployment

 - Create a GitHub access token:
	 - go to your GitHub profile, and in the top-right corner **click on your profile image**, then click on "**Settings**";
	 - click on "**development settings**", then "**Personal access tokens**";
	 - click on "**Generate new token**", give it a name and the correct permissions. Then click on "**Generate token**".
 - Go to the development group you created (***development_group***), then click on "**Create deployment**".
 - Select "**My application is stored in GitHub**"; paste the token from GitHub and click on "**Connect to GitHub**"
 - Paste the **Repository name** and the **Commit ID** of your first commit.
 - In the "Additional deployment behavior settings" section, select "**Overwrite the content**".
 - Click on "**Create deployment**".

## 11. Create GitHub Actions 

-   In your project folder, **create a folder** and name it `.github`. Mind the dot before github. Inside that folder, **create another folder** called `workflows`. Inside that folder, **create a file** called `deploy.yml` containing the following:
```yml
name: EC2 CodeDeploy CI/CD pipeline
on:
  push:
    branches: [ master ]

jobs:
  continuous-integration:
    runs-on: ubuntu-latest
    steps:
      # Step 1
      - name: Checkout repository
        uses: actions/checkout@v2
      # Step 2
      - name: Use Node.js 14.x
        uses: actions/setup-node@v1
        with:
          node-version: 14.x

  continuous-deployment:
    runs-on: ubuntu-latest
    needs: [continuous-integration]
    if: github.ref == 'refs/heads/master'
    steps:
     # Step 1
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: eu-central-1
     # Step 2
      - name: Create CodeDeploy Deployment
        id: deploy
        run: |
          aws deploy create-deployment \
            --application-name Git_Application \
            --deployment-group-name development_group \
            --deployment-config-name CodeDeployDefault.OneAtATime \
            --github-location repository=${{ github.repository }},commitId=${{ github.sha }}
```
-   **Commit and push** your changes, then go to your GitHub repo; click on the "**Actions**" panel to verify the workflows is correctly running and that the jobs finishes successfully.

## 12. Verify the automated deployment was successful

 - In your AWS account, go to the **CodeDeploy control panel**: https://console.aws.amazon.com/codesuite/codedeploy/home
 - Now you should see a deployment hopefully ***Succeeded***. Click on it's **Deployment Id**.
 - To view more details, click on "**View Events**" in the "**Deployment lifecycle events**" section.

**Congratulations, you successfully completed this tutorial!**
