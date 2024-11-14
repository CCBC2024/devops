# Create backend repository

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# build backend docker image
build_docker_image $backend_directory $backend_docker_image_name

# test the docker image
#test_docker_image $backend_docker_image_name $backend_test_port $backend_test_path