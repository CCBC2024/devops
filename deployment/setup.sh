# setup all AWS resources for charity donation application

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

echo "Start to setup all AWS resources for charity donation application..."

# provision all the AWS resources in the stage 2 and stage 3
sh ./charity-donation-deployment/setup-stage2.sh
sh ./charity-donation-deployment/setup-stage3.sh

# clean docker containers and images for saving disk space
docker system prune --all --volumes -f

# provision all the AWS resources in the stage 4
sh ./charity-donation-deployment/setup-stage4.sh

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# get the load balancer DNS name
LOAD_BALANCER_DNS=$(get_load_balancer_dns_name "$load_balancer_name")

# print the load balancer DNS name
echo "All commands are executed successfully.
After the deployment is completed, you can access the charity donation application at http://$LOAD_BALANCER_DNS"