# create backend erc repository

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# create backend erc repository
create_ecr_repository $backend_source_code
