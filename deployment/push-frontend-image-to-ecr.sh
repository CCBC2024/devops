# push backend image to ecr

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# push frontend image to ecr
push_docker_image_to_ecr $frontend_docker_image_name