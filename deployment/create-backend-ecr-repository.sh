# create backend erc repository

# import variables
source variables.sh

# import common functions
source common.sh

# create backend erc repository
create_ecr_repository $backend_source_code
