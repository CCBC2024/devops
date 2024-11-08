# Create backend repository

# import variables
source ./variables.sh

# import common functions
source ./common.sh

# build frontend docker image
build_docker_image $frontend_directory $frontend_docker_image_name

# test the docker image
#test_docker_image $frontend_docker_image_name $frontend_test_port $backend_test_path