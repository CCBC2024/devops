# for variables that are used in the deployment scripts

# root directory
root_directory="$HOME/environment/charity-donation-application"

# relative paths
ci_cd_path="cicd"
ecs_path="ecs"
code_deploy_path="$ci_cd_path/code-deploy"
code_pipeline_path="$ci_cd_path/code-pipeline"
task_definition_path="$ecs_path/task-definition"

# directories
deployment_directory="${root_directory}/charity-donation-deployment"
cloudformation_directory="${deployment_directory}/cloudformation"
ecs_directory="${deployment_directory}/$ecs_path"
task_definition_directory="${ecs_directory}/task-definition"
ecs_service_directory="${ecs_directory}/service"
code_pipeline_directory="${deployment_directory}/$code_pipeline_path"
git_hook_directory="${deployment_directory}/git-hook"

# vpc cloudformation stack
export vpc_stack_name="vpc-stack"
export vpc_stack_template="${cloudformation_directory}.yaml"

# frontend and backend source code name
export frontend_source_code="charity-donation-frontend"
export backend_source_code="charity-donation-backend"
export deployment_source_code="charity-donation-deployment"

# frontend and backend directory path
export frontend_directory="${root_directory}/${frontend_source_code}"
export backend_directory="${root_directory}/${backend_source_code}"

# frontend and backend docker image name, currently the same as the source code name
export frontend_docker_image_name="${frontend_source_code}"
export backend_docker_image_name="${backend_source_code}"

# frontend and backend test port
export frontend_test_port=3000
export backend_test_port=3030

# frontend and backend test url path
export frontend_test_path="/"
export backend_test_path="/health"

# ecs cluster name
export ecs_cluster_name="blockchain-charity-cluster"

# ecs frontend task definitions
export ecs_frontend_task_definition_path="${task_definition_directory}/${frontend_source_code}.json"
export ecs_frontend_task_definition_deploy_path="${task_definition_directory}/${frontend_source_code}-deploy.json"
export ecs_frontend_task_definition_template_path="${task_definition_directory}/${frontend_source_code}-template.json"

# ecs backend task definitions
export ecs_backend_task_definition_path="${task_definition_directory}/${backend_source_code}.json"
export ecs_backend_task_definition_deploy_path="${task_definition_directory}/${backend_source_code}-deploy.json"
export ecs_backend_task_definition_template_path="${task_definition_directory}/${backend_source_code}-template.json"

# ecs service names
export frontend_ecs_service_path="${ecs_service_directory}/${frontend_source_code}.json"
export backend_ecs_service_path="${ecs_service_directory}/${backend_source_code}.json"
export frontend_ecs_service_template_path="${ecs_service_directory}/${frontend_source_code}-template.json"
export backend_ecs_service_template_path="${ecs_service_directory}/${backend_source_code}-template.json"

# security group name
export security_group_name="charityDonationSG"

# load balancer name
export load_balancer_name="charityDonationLB"

# subnet names
export public_subnet1_name="Public Subnet1"
export public_subnet2_name="Public Subnet2"

# target group names
export frontend_tg_one_name="frontend-tg-one"
export frontend_tg_two_name="frontend-tg-two"
export backend_tg_one_name="backend-tg-one"
export backend_tg_two_name="backend-tg-two"

# backend path patterns
export backend_path_pattern="/api/*"

# listener ports
export listener_port_80="80"
export listener_port_8080="8080"

# health check path
export frontend_health_check_path="/"
export backend_health_check_path="/health"

# code deploy
export code_deploy_application_name="charity-donation"
export frontend_deployment_group_name="${frontend_source_code}"
export backend_deployment_group_name="${backend_source_code}"
export deploy_role_name="DeployRole"

# code pipelines
export pipeline_role_name="PipelineRole"
export frontend_pipeline_name="${frontend_source_code}"
export backend_pipeline_name="${backend_source_code}"
export frontend_pipeline_bucket_name="${frontend_source_code}-pipeline"
export backend_pipeline_bucket_name="${backend_source_code}-pipeline"
export pipeline_template_path="${code_pipeline_directory}/pipeline-template.json"
export frontend_pipeline_path="${code_pipeline_directory}/$frontend_source_code-pipeline.json"
export backend_pipeline_path="${code_pipeline_directory}/$backend_source_code-pipeline.json"
export frontend_task_definition_pipeline_path="${task_definition_path}/$frontend_source_code-deploy.json"
export backend_task_definition_pipeline_path="${task_definition_path}/$backend_source_code-deploy.json"
export frontend_appspec_pipeline_path="${code_deploy_path}/$frontend_source_code-appspec.yaml"
export backend_appspec_pipeline_path="${code_deploy_path}/$backend_source_code-appspec.yaml"

# git hooks
export backend_git_pre_commit_hook_path="${git_hook_directory}/$backend_source_code-pre-commit"
export frontend_git_pre_commit_hook_path="${git_hook_directory}/$frontend_source_code-pre-commit"
export backend_git_pre_push_hook_path="${git_hook_directory}/$backend_source_code-pre-push"
export frontend_git_pre_push_hook_path="${git_hook_directory}/$frontend_source_code-pre-push"

