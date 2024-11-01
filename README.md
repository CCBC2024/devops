# DevOps

# Prerequisites
## Set up the AWS CLI credentials
We assumed that you have already installed the AWS CLI by the guide [here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).

To set up the AWS CLI credentials, you must start the Learner Lab environment first.
Then you click on the AWS Details in the top right corner of the Learner Lab.
You will see the AWS CLI with the Show button on the right side to show the AWS CLI credentials.
You will also see the Region at the bottom of the AWS Details.
Set up the AWS CLI credentials by the guide [here](https://docs.aws.amazon.com/cli/latest/userguide/cli-authentication-short-term.html).

## Set up the VPC by the CloudFormation stack
Navigate to the `deployment` folder and run the following command to create the VPC by the CloudFormation stack:
```
sh setup-vpc.sh
```
After the stack is created, you will see the output of the stack with the VPC ID, Subnet IDs in the output tab of the vpc stack in the CloudFormation console.

We can clean up the VPC for cost-saving by running the following command:
```
sh cleanup-vpc.sh
```
When the command is finished, you can see the stack is disappeared in the CloudFormation console.

Figure 1. The AWS Details in the Learner Lab
Figure 2. The vpc stack is created
Figure 3. The output of the vpc stack in the CloudFormation console
Figure 4. The vpc stack is deleted
Figure 5. The vpc stack is disappeared in the CloudFormation console


