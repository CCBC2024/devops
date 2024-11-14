# create backend task definition

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

# get aws credentials from entered values
read -r -p "Enter AWS_ACCESS_KEY_ID: " AWS_ACCESS_KEY_ID
read -r -p "Enter AWS_SECRET_ACCESS_KEY: " AWS_SECRET_ACCESS_KEY
read -r -p "Enter AWS_SESSION_TOKEN (leave empty if not applicable): " AWS_SESSION_TOKEN

# define environment variables
AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN:-}"
ACCOUNT_ID=$(get_account_id)

# update environment variables
sed -e "s|<AWS_ACCESS_KEY_ID>|$AWS_ACCESS_KEY_ID|g" \
    -e "s|<AWS_SECRET_ACCESS_KEY>|$AWS_SECRET_ACCESS_KEY|g" \
    -e "s|<AWS_SESSION_TOKEN>|$AWS_SESSION_TOKEN|g" \
    -e "s|<ACCOUNT_ID>|$ACCOUNT_ID|g" \
    "$ecs_backend_task_definition_template_path" > "$ecs_backend_task_definition_path"

# create backend task definition
create_ecs_task_definition $ecs_backend_task_definition_path