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

# wait for stack deletion to complete function, takes stack name as argument
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
# takes stack name and output key as arguments
# ref: https://docs.aws.amazon.com/cli/latest/reference/cloudformation/describe-stacks.html
# ref: https://stackoverflow.com/questions/41628487/getting-outputs-from-aws-cloudformation-describe-stacks
get_stack_output() {
    local stack_name=$1
    local output_key=$2
    aws cloudformation describe-stacks --stack-name "$stack_name" --query "Stacks[0].Outputs[?OutputKey=='$output_key'].OutputValue" --output text
}

# create code commit repository function
# takes repository name as first argument
# takes repository description as second argument
create_codecommit_repository() {
    local repository_name=$1
    local repository_description=$2

    echo "Creating codecommit repository $repository_name ..."
    aws codecommit create-repository --repository-name "$repository_name" --repository-description "$repository_description"
    if [ $? -ne 0 ]; then
        echo "$repository_name creation failed"
        exit 1
    fi
    echo "$repository_name created successfully"
}

# initialize codecommit source code function
# takes repository name as first argument
# takes source code directory as second argument
initialize_codecommit_source_code() {
    local repository_name=$1
    local source_code_dir=$2

    echo "Initializing codecommit source code for $repository_name ..."
    cd "$source_code_dir" || exit
    rm -rf .git/
    git init
    git branch -m dev
    git add .
    git commit -m 'add latest code to code commit'
    git remote add origin "https://git-codecommit.$(aws configure get region).amazonaws.com/v1/repos/$repository_name"
    git push -u origin dev
    if [ $? -ne 0 ]; then
        echo "Codecommit $repository_name source code initialization failed"
        exit 1
    fi
    echo "Codecommit $repository_name source code initialized successfully"
}

# build the docker image function
# takes source code directory as first argument
# takes docker image name as second argument
build_docker_image() {
    local source_code_dir=$1
    local docker_image_name=$2

    echo "Building docker image from $source_code_dir ..."
    cd "$source_code_dir" || exit
    docker build -t "$docker_image_name" .
    if [ $? -ne 0 ]; then
        echo "Docker image $docker_image_name build failed"
        exit 1
    fi

    # check if the docker image is built successfully
    docker images | grep "$docker_image_name"
    if [ $? -ne 0 ]; then
        echo "Docker image $docker_image_name build failed"
        exit 1
    fi

    echo "Docker image $docker_image_name build successfully"
}

# test docker image function
# takes docker image name as first argument
# takes port as second argument
# takes path as third argument
test_docker_image() {
    local docker_image_name=$1
    local port=$2
    local path=$3
    local container_name=$docker_image_name

    echo "Running docker image $docker_image_name ..."
    docker run -d -p $port:$port --name $container_name $docker_image_name
    if [ $? -ne 0 ]; then
        echo "Docker image $docker_image_name run failed"
        exit 1
    fi

    echo "Testing if the URL is accessible on localhost:$port$path ..."
    curl -f http://localhost:$port$path
    if [ $? -ne 0 ]; then
        echo "URL is not accessible on localhost:$port$path"
        docker stop $container_name
        docker rm $container_name
        exit 1
    fi

    echo "URL is accessible on localhost:$port$path"
    docker stop $container_name
    docker rm $container_name
}

# create ecr repository function
# takes repository name as argument
create_ecr_repository() {
    local repository_name=$1
    echo "Creating ECR repository $repository_name ..."
    aws ecr create-repository --repository-name "$repository_name"
    if [ $? -ne 0 ]; then
        echo "ECR repository $repository_name creation failed"
        exit 1
    fi
    echo "ECR repository $repository_name created successfully"

    echo "Setting repository policy for $repository_name ..."
    aws ecr set-repository-policy \
    --repository-name "$repository_name" \
    --policy-text '{
        "Version": "2008-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": "*",
                "Action": "ecr:*"
            }
        ]
    }'
    if [ $? -ne 0 ]; then
        echo "Setting policy for ECR repository $repository_name failed"
        exit 1
    fi
    echo "Policy for ECR repository $repository_name set successfully"
}

# get account id function
get_account_id() {
    aws sts get-caller-identity | grep Account | cut -d '"' -f4
}

# push docker image to ecr function
# takes docker image name as argument
push_docker_image_to_ecr() {
    local docker_image_name=$1
    local account_id
    account_id=$(get_account_id)
    echo "Pushing docker image $docker_image_name to ECR..."
    aws ecr get-login-password --region "$(aws configure get region)" | docker login --username AWS --password-stdin "$account_id.dkr.ecr.$(aws configure get region).amazonaws.com"
    docker tag "$docker_image_name":latest "$account_id.dkr.ecr.$(aws configure get region).amazonaws.com/$docker_image_name":latest
    docker push "$account_id.dkr.ecr.$(aws configure get region).amazonaws.com/$docker_image_name":latest
    if [ $? -ne 0 ]; then
        echo "Pushing docker image $docker_image_name to ECR failed"
        exit 1
    fi
    echo "Docker image $docker_image_name pushed to ECR successfully"
}

# create ecs cluster function
# takes cluster name as argument
create_ecs_cluster() {
    local cluster_name=$1
    echo "Creating ECS cluster $cluster_name ..."
    aws ecs create-cluster \
        --cluster-name "$cluster_name" \
        --capacity-providers FARGATE \
        --vpc-configuration "subnets=PublicSubnet1,PublicSubnet2,vpc=LabVPC"
    if [ $? -ne 0 ]; then
        echo "ECS cluster $cluster_name creation failed"
        exit 1
    fi
    echo "ECS cluster $cluster_name created successfully"
}

# create ecs task definition function
# takes task definition file as argument
create_ecs_task_definition() {
    local task_definition_file=$1
    echo "Creating ECS task definition from $task_definition_file ..."
    aws ecs register-task-definition --cli-input-json "file://$task_definition_file"
    if [ $? -ne 0 ]; then
        echo "ECS task definition creation failed"
        exit 1
    fi
    echo "ECS task definition created successfully"
}