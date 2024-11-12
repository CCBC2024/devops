# create backend task definition

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# define environment variables
AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
AWS_ACCESS_KEY_ID="AWS_ACCESS"
AWS_SESSION_TOKEN="AWS_SESSION"
ACCOUNT_ID=$(get_account_id)

# update environment variables
sed -e "s|<AWS_ACCESS_KEY_ID>|$AWS_ACCESS_KEY_ID|g" \
    -e "s|<AWS_SECRET_ACCESS_KEY>|$AWS_SECRET_ACCESS_KEY|g" \
    -e "s|<AWS_SESSION_TOKEN>|$AWS_SESSION_TOKEN|g" \
    -e "s|<ACCOUNT_ID>|$ACCOUNT_ID|g" \
    "$ecs_backend_task_definition_template_path" > "$ecs_backend_task_definition_path"

# create backend task definition
create_ecs_task_definition $ecs_backend_task_definition_path