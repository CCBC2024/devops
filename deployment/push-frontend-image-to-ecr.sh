# push backend image to ecr

# import variables
source ./variables.sh

# import common functions
source ./common.sh

# push frontend image to ecr
push_docker_image_to_ecr $frontend_docker_image_name