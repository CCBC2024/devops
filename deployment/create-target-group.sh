# Create target groups

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# create frontend-tg-one
create_target_group "$frontend_tg_one_name" "$frontend_health_check_path"

# create frontend-tg-two
create_target_group "$frontend_tg_two_name" "$frontend_health_check_path"

# create backend-tg-one
create_target_group "$backend_tg_one_name" "$backend_health_check_path"

# create backend-tg-two
create_target_group "$backend_tg_two_name" "$backend_health_check_path"