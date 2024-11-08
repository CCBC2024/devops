# Create backend repository

# import variables
source variables.sh

# import common functions
source common.sh

# create backend repository
create_codecommit_repository $backend_source_code "Charity Donation Backend Repository"

# initialize backend source code
initialize_codecommit_source_code $backend_directory $backend_source_code