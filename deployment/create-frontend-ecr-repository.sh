# create frontend erc repository

# import variables
source variables.sh

# import common functions
source common.sh

# create frontend erc repository
create_ecr_repository $frontend_source_code
