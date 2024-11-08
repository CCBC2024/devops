# Create backend repository

# import variables
source ./variables.sh

# import common functions
source ./common.sh

# create frontend repository
create_codecommit_repository $frontend_source_code "Charity Donation Frontend Repository"

# initialize frontend source code
initialize_codecommit_source_code $frontend_source_code $frontend_directory