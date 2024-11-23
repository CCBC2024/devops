# setup codedeploy for charity donation application

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# create codedeploy application
create_code_deploy_application "$code_deploy_application_name"

# define environment variables
deploy_role_arn=$(get_iam_role_arn "$deploy_role_name")
listener_80_arn=$(get_listener_arn "$load_balancer_name" "$listener_port_80")
listener_8080_arn=$(get_listener_arn "$load_balancer_name" "$listener_port_8080")

# create code deploy deployment group for frontend
create_code_deploy_deployment_group \
    "$code_deploy_application_name" \
    "$frontend_deployment_group_name" \
    "$deploy_role_arn" \
    "$ecs_cluster_name" \
    "$frontend_source_code" \
    "$frontend_tg_one_name" \
    "$frontend_tg_two_name" \
    "$listener_80_arn" \
    "$listener_8080_arn"

# create code deploy deployment group for backend
create_code_deploy_deployment_group \
    "$code_deploy_application_name" \
    "$backend_deployment_group_name" \
    "$deploy_role_arn" \
    "$ecs_cluster_name" \
    "$backend_source_code" \
    "$backend_tg_one_name" \
    "$backend_tg_two_name" \
    "$listener_80_arn" \
    "$listener_8080_arn"
