# create frontend task definition

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# define environment variables
NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS="0x7C1FcD9b02DF2d950463609BA7bd2229eA8BC991"
LOAD_BALANCER_DNS=$(get_load_balancer_dns_name $load_balancer_name)
NEXT_PUBLIC_BACKEND_API_URL="http://$LOAD_BALANCER_DNS"
ACCOUNT_ID=$(get_account_id)

# update environment variables
sed -e "s|<NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS>|$NEXT_PUBLIC_CHARITY_CONTRACT_ADDRESS|g" \
    -e "s|<NEXT_PUBLIC_BACKEND_API_URL>|$NEXT_PUBLIC_BACKEND_API_URL|g" \
    -e "s|<ACCOUNT_ID>|$ACCOUNT_ID|g" \
    "$ecs_frontend_task_definition_template_path" > "$ecs_frontend_task_definition_path"

# create frontend task definition
create_ecs_task_definition $ecs_frontend_task_definition_path