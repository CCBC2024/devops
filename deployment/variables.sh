# for variables that are used in the deployment scripts

# vpc cloudformation stack
export vpc_stack_name="vpc-stack"
export vpc_stack_template="${vpc_stack_name}.yaml"

# frontend and backend source code name
export frontend_source_code="charity-donation-frontend"
export backend_source_code="charity-donation-backend"

# frontend and backend directory path
export frontend_directory="$HOME/environment/charity-donation-application/${frontend_source_code}"
export backend_directory="$HOME/environment/charity-donation-application/${backend_source_code}"

# frontend and backend docker image name, currently the same as the source code name
export frontend_docker_image_name="${frontend_source_code}"
export backend_docker_image_name="${backend_source_code}"

# frontend and backend test port
export frontend_test_port=3000
export backend_test_port=3030

# frontend and backend test url path
export frontend_test_path="/"
export backend_test_path="/health"