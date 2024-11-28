# create frontend task definition

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

# define environment variables
NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS="0x88C2d310a615A4B9EcCdf12519aa2cdc431684b3"
LOAD_BALANCER_DNS=$(get_load_balancer_dns_name $load_balancer_name)
NEXT_PUBLIC_BACKEND_API_URL="http://$LOAD_BALANCER_DNS"
IMAGE1_NAME="frontend" # image name for frontend service
ACCOUNT_ID=$(get_account_id)

# update environment variables to the frontend task definition
sed -e "s|<NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS>|$NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS|g" \
    -e "s|<NEXT_PUBLIC_BACKEND_API_URL>|$NEXT_PUBLIC_BACKEND_API_URL|g" \
    -e "s|<ACCOUNT_ID>|$ACCOUNT_ID|g" \
    -e "s|<IMAGE1_NAME>|$IMAGE1_NAME|g" \
    "$ecs_frontend_task_definition_template_path" > "$ecs_frontend_task_definition_path"

# update environment variables to the frontend task definition for deployment
sed -e "s|<NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS>|$NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS|g" \
    -e "s|<NEXT_PUBLIC_BACKEND_API_URL>|$NEXT_PUBLIC_BACKEND_API_URL|g" \
    -e "s|<ACCOUNT_ID>|$ACCOUNT_ID|g" \
    "$ecs_frontend_task_definition_template_path" > "$ecs_frontend_task_definition_deploy_path"

# create frontend task definition
create_ecs_task_definition $ecs_frontend_task_definition_path