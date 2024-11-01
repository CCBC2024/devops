# common functions for deployment scripts

# validate cloudformation template function, takes template file name as input
# ref:https://docs.aws.amazon.com/cli/latest/reference/cloudformation/validate-template.html
validate_cloudformation_template() {
    local template_file=$1
    echo "Validating cloudformation template $template_file..."
    aws cloudformation validate-template --template-body file://"$template_file"
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

# create cloudformation stack function
# takes stack name as first argument
# takes template file as second argument
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/create-stack.html
create_cloudformation_stack() {
    local stack_name=$1
    local template_file=$2

    echo "Creating $stack_name ..."
    aws cloudformation create-stack --stack-name "$stack_name" --template-body file://"$template_file"
    if [ $? -ne 0 ]; then
        echo "$stack_name creation failed"
        exit 1
    fi

    wait_for_stack_creation "$stack_name"
}

# wait for stack creation to complete function, takes stack name as input
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/wait/stack-create-complete.html
wait_for_stack_creation() {
    local stack_name=$1
    echo "Waiting for $stack_name creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name "$stack_name"
    if [ $? -ne 0 ]; then
        echo "$stack_name creation failed"
        exit 1
    fi
    echo "$stack_name created successfully"
}

# delete cloudformation stack function, takes stack name as input
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/delete-stack.html
delete_cloudformation_stack() {
    local stack_name=$1
    echo "Deleting ${stack_name} stack..."
    aws cloudformation delete-stack --stack-name "$stack_name"
    if [ $? -ne 0 ]; then
        echo "${stack_name} stack deletion failed"
        exit 1
    fi

    wait_for_stack_deletion "$stack_name"
}

# wait for stack deletion to complete function, takes stack name as input
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/wait/stack-delete-complete.html
wait_for_stack_deletion() {
  aws cloudformation wait stack-delete-complete --stack-name "$stack_name"
    if [ $? -ne 0 ]; then
        echo "${stack_name} stack deletion failed"
        exit 1
    fi
    echo "${stack_name} stack deleted successfully"
}

# get stack output function,
# takes stack name and output key as input
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/describe-stacks.html
# ref: https://stackoverflow.com/questions/41628487/getting-outputs-from-aws-cloudformation-describe-stacks
get_stack_output() {
    local stack_name=$1
    local output_key=$2
    aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].Outputs[?OutputKey=='$output_key'].OutputValue" --output text
}
