# create frontend ecs service

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

# define local variables
revision_number=$(get_task_definition_revision_number $frontend_source_code)
subnet1_id=$(get_subnet_id "$public_subnet1_name")
subnet2_id=$(get_subnet_id "$public_subnet2_name")
security_group_id=$(get_security_group_id $security_group_name)
tg_two_arn=$(get_target_group_arn $frontend_tg_two_name)

# update the service configuration from the template
sed -e "s|REVISION-NUMBER|$revision_number|g" \
    -e "s|PUBLIC-SUBNET-1-ID|$subnet1_id|g" \
    -e "s|PUBLIC-SUBNET-2-ID|$subnet2_id|g" \
    -e "s|SECURITY-GROUP-ID|$security_group_id|g" \
    -e "s|CHARITY-TG-TWO-ARN|$tg_two_arn|g" \
    "$frontend_ecs_service_template_path" > "$frontend_ecs_service_path"

# create frontend ecs service
create_ecs_service "$frontend_source_code" "$frontend_ecs_service_path"