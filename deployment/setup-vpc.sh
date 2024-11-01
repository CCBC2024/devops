# setup vpc by cloudformation

# import the common functions
source common.sh

# import the variables
source variables.sh

# validate cloudformation template
validate_cloudformation_template $vpc_stack_template

# create cloudformation stack
create_cloudformation_stack $vpc_stack_name $vpc_stack_template

# get vpc id
vpc_id=$(get_stack_output $vpc_stack_name "VpcId")
echo -e "\n--> The vpc was created with id: $vpc_id"