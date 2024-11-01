# clean the vpc stack

# import the common functions
source common.sh

# import the variables
source variables.sh

# delete cloudformation stack
delete_cloudformation_stack $vpc_stack_name