# for variables that are used in the deployment scripts

# root directory
root_directory="$HOME/environment/charity-donation-application"

# directories
deployment_directory="${root_directory}/charity-donation-deployment"
cloudformation_directory="${deployment_directory}/cloudformation"
ecs_directory="${deployment_directory}/ecs"
task_definition_directory="${ecs_directory}/task-definition"

# vpc cloudformation stack
export vpc_stack_name="vpc-stack"
export vpc_stack_template="${cloudformation_directory}.yaml"

# frontend and backend source code name
export frontend_source_code="charity-donation-frontend"
export backend_source_code="charity-donation-backend"

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

# ecs task definitions
export ecs_frontend_task_definition_path="${task_definition_directory}/${frontend_source_code}.json"
export ecs_backend_task_definition_path="${task_definition_directory}/${backend_source_code}.json"
export ecs_frontend_task_definition_template_path="${task_definition_directory}/${frontend_source_code}-template.json"
export ecs_backend_task_definition_template_path="${task_definition_directory}/${backend_source_code}-template.json"

# load balancer name
export load_balancer_name="charityDonationLB"
