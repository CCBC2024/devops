# create frontend erc repository

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# create frontend erc repository
create_ecr_repository $frontend_source_code
