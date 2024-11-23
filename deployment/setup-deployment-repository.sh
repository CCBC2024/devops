# Create backend repository

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# create backend repository
create_codecommit_repository $deployment_source_code "Charity Donation Deployment Repository"

# initialize backend source code
initialize_codecommit_source_code $deployment_source_code $deployment_directory