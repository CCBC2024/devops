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
        --capacity-providers FARGATE
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

# create target group function
# takes target group name as first argument
# takes health check path as second argument
create_target_group() {
    local target_group_name=$1
    local health_check_path=$2
    local vpc_id
    vpc_id=$(get_vpc_id)
    echo "Creating target group $target_group_name ..."
    aws elbv2 create-target-group \
        --name "$target_group_name" \
        --protocol HTTP \
        --port 8080 \
        --vpc-id "$vpc_id" \
        --target-type ip \
        --health-check-path "$health_check_path"
    if [ $? -ne 0 ]; then
        echo "Target group $target_group_name creation failed"
        exit 1
    fi
    echo "Target group $target_group_name created successfully"
}

# create security group function
# takes security group name as argument
create_security_group() {
    local security_group_name=$1
    local vpc_id
    vpc_id=$(get_vpc_id)
    echo "Creating security group $security_group_name ..."
    aws ec2 create-security-group \
        --group-name "$security_group_name" \
        --description "Security group for charity donation platform allowing HTTP and custom port" \
        --vpc-id "$vpc_id"
    if [ $? -ne 0 ]; then
        echo "Security group $security_group_name creation failed"
        exit 1
    fi
    echo "Security group $security_group_name created successfully"
}

# add inbound rules tcp security group function
# takes security group name as first argument
# takes port as second argument
add_inbound_rules_tcp_security_group() {
    local security_group_name=$1
    local port=$2
    local security_group_id
    security_group_id=$(get_security_group_id "$security_group_name")
    echo "Adding inbound rules that allow TCP traffic from any IPv4 address on port $port ..."
    aws ec2 authorize-security-group-ingress \
        --group-id "$security_group_id" \
        --protocol tcp \
        --port "$port" \
        --cidr 0.0.0.0/0

    if [ $? -ne 0 ]; then
        echo "Adding inbound rules for security group $security_group_name failed"
        exit 1
    fi
    echo "Inbound rules added successfully for security group $security_group_name"
}

# create load balancer function
# takes load balancer name as first argument
# takes security group name as second argument
# takes subnet names as third argument and fourth argument
create_load_balancer() {
    local load_balancer_name=$1
    local security_group_name=$2
    local subnet1_name=$3
    local subnet2_name=$4
    local security_group_id
    local subnet1_id
    local subnet2_id
    security_group_id=$(get_security_group_id "$security_group_name")
    subnet1_id=$(get_subnet_id "$subnet1_name")
    subnet2_id=$(get_subnet_id "$subnet2_name")
    echo "Creating load balancer $load_balancer_name ..."
    aws elbv2 create-load-balancer \
        --name "$load_balancer_name" \
        --subnets "$subnet1_id" "$subnet2_id" \
        --security-groups "$security_group_id" \
        --scheme internet-facing \
        --type application \
        --ip-address-type ipv4
    if [ $? -ne 0 ]; then
        echo "Load balancer $load_balancer_name creation failed"
        exit 1
    fi
    echo "Load balancer $load_balancer_name created successfully"

    echo "Waiting until load balancer available..."
    aws elbv2 wait load-balancer-available --names "$load_balancer_name"
    if [ $? -ne 0 ]; then
        echo "Load balancer $load_balancer_name is not available"
        exit 1
    fi
    echo "Load balancer $load_balancer_name is available"
}

# create listener function
# takes load balancer name as first argument
# takes listener port as second argument
# takes target group arn as third argument
create_listener() {
    local load_balancer_name=$1
    local listener_port=$2
    local target_group_name=$3
    local load_balancer_arn
    local target_group_arn
    load_balancer_arn=$(get_load_balancer_arn "$load_balancer_name")
    target_group_arn=$(get_target_group_arn "$target_group_name")
    echo "Creating listener on port $listener_port for load balancer $load_balancer_name ..."
    aws elbv2 create-listener \
        --load-balancer-arn "$load_balancer_arn" \
        --protocol HTTP \
        --port "$listener_port" \
        --default-actions Type=forward,TargetGroupArn="$target_group_arn"
    if [ $? -ne 0 ]; then
        echo "Listener creation on port $listener_port for load balancer $load_balancer_name failed"
        exit 1
    fi
    echo "Listener created on port $listener_port for load balancer $load_balancer_name successfully"
}

# add rule to listener function
# takes listener arn as first argument
# takes path as second argument
# takes target group name as third argument
add_rule_to_listener() {
    local listener_arn=$1
    local path=$2
    local target_group_name=$3
    local target_group_arn
    target_group_arn=$(get_target_group_arn "$target_group_name")
    echo "Adding rule to listener $listener_arn ..."
    aws elbv2 create-rule \
        --listener-arn "$listener_arn" \
        --conditions Field=path-pattern,Values="$path" \
        --priority 1 \
        --actions Type=forward,TargetGroupArn="$target_group_arn"
    if [ $? -ne 0 ]; then
        echo "Adding rule to listener $listener_arn failed"
        exit 1
    fi
    echo "Rule added to listener $listener_arn successfully"
}

# create ecs service function
# takes service name as first argument
# takes configuration file path as second argument
create_ecs_service() {
    local service_name=$1
    local configuration_file_path=$2
    echo "Creating ECS service $service_name ..."
    aws ecs create-service --service-name "$service_name" --cli-input-json "file://$configuration_file_path"
    if [ $? -ne 0 ]; then
        echo "ECS service $service_name creation failed"
        exit 1
    fi
    echo "ECS service $service_name created successfully"
}

# create code deploy application function
# takes application name as argument
create_code_deploy_application() {
    local application_name=$1
    echo "Creating codedeploy application $application_name ..."

    aws deploy create-application --application-name "$application_name" --compute-platform ECS
    if [ $? -ne 0 ]; then
        echo "Codedeploy application $application_name creation failed"
        exit 1
    fi

    # verify application running
    aws deploy get-application --application-name "$application_name"
    if [ $? -ne 0 ]; then
        echo "Failed to verify Codedeploy application $application_name"
        exit 1
    fi

    echo "Codedeploy application $application_name created successfully"
}

# create code deploy deployment group function
# takes application name as first argument
# takes deployment group name as second argument
# takes deploy role arn as third argument
# takes cluster name as fourth argument
# takes service name as fifth argument
# takes target group one name as sixth argument
# takes target group two name as seventh argument
# takes listener 80 arn as eighth argument
# takes listener 8080 arn as ninth argument
create_code_deploy_deployment_group() {
    local application_name=$1
    local deployment_group_name=$2
    local deploy_role_arn=$3
    local cluster_name=$4
    local service_name=$5
    local target_group_one_name=$6
    local target_group_two_name=$7
    local listener_80_arn=$8
    local listener_8080_arn=$9

    echo "Creating code deploy group $deployment_group_name for $service_name ..."
    aws deploy create-deployment-group \
        --application-name "$application_name" \
        --deployment-group-name "$deployment_group_name" \
        --service-role-arn "$deploy_role_arn" \
        --deployment-config-name CodeDeployDefault.ECSAllAtOnce \
        --ecs-services clusterName="$cluster_name",serviceName="$service_name" \
        --load-balancer-info "targetGroupPairInfoList=[{targetGroups=[{name=$target_group_two_name},{name=$target_group_one_name}],prodTrafficRoute={listenerArns=[\"$listener_80_arn\"]},testTrafficRoute={listenerArns=[\"$listener_8080_arn\"]}}]" \
        --deployment-style deploymentType=BLUE_GREEN,deploymentOption=WITH_TRAFFIC_CONTROL \
        --blue-green-deployment-configuration "terminateBlueInstancesOnDeploymentSuccess={action=TERMINATE,terminationWaitTimeInMinutes=5},deploymentReadyOption={actionOnTimeout=CONTINUE_DEPLOYMENT}"
    if [ $? -ne 0 ]; then
        echo "Code deploy group $deployment_group_name creation failed"
        exit 1
    fi
    echo "Code deploy group $deployment_group_name created successfully"
}

# generate unique s3 bucket name function
# takes bucket name as argument
generate_unique_s3_bucket_name() {
    local bucket_name=$1
    echo "${bucket_name}-$(date +%s)"
}

# create s3 bucket function
# takes bucket name as argument
create_s3_bucket() {
    local bucket_name=$1
    echo "Creating S3 bucket $bucket_name ..."
    aws s3api create-bucket --bucket "$bucket_name" --region "$(get_region)"
    if [ $? -ne 0 ]; then
        echo "S3 bucket $bucket_name creation failed"
        exit 1
    fi
    echo "S3 bucket $bucket_name created successfully"
}

# create code pipeline function
# takes pipeline name as first argument
# takes pipeline configuration file as second argument
create_code_pipeline() {
    local pipeline_name=$1
    local pipeline_configuration_file=$2

    echo "Creating code pipeline $pipeline_name ..."
    aws codepipeline create-pipeline --cli-input-json "file://$pipeline_configuration_file" --region "$(get_region)"
    if [ $? -ne 0 ]; then
        echo "Code pipeline $pipeline_name creation failed"
        exit 1
    fi
    echo "Code pipeline $pipeline_name created successfully"
}

# get vpc id function for the vpc with tag Name=LabVPC
get_vpc_id() {
    aws ec2 describe-vpcs --filters "Name=tag:Name,Values=LabVPC" --query "Vpcs[*].VpcId" --output text
}

# get security group id function
# takes security group name as argument
get_security_group_id() {
  local security_group_name=$1
  aws ec2 describe-security-groups --filters "Name=group-name,Values=$security_group_name" --query "SecurityGroups[0].GroupId" --output text
}

# get subnet id function
# takes subnet name as argument
get_subnet_id() {
  local subnet_name=$1
  aws ec2 describe-subnets --filters "Name=tag:Name,Values=$subnet_name" --query "Subnets[0].SubnetId" --output text
}

# get load balancer arn function
# takes load balancer name as argument
get_load_balancer_arn() {
    local load_balancer_name=$1
    aws elbv2 describe-load-balancers --names "$load_balancer_name" --query "LoadBalancers[0].LoadBalancerArn" --output text
}

# get load balancer dns name function
# takes load balancer name as argument
get_load_balancer_dns_name() {
    local load_balancer_name=$1
    aws elbv2 describe-load-balancers --names "$load_balancer_name" --query "LoadBalancers[0].DNSName" --output text
}

# get target group arn function
# takes target group name as argument
get_target_group_arn() {
    local target_group_name=$1
    aws elbv2 describe-target-groups --names "$target_group_name" --query "TargetGroups[0].TargetGroupArn" --output text
}

# get listener arn function
# takes load balancer name as first argument
# takes port as second argument
get_listener_arn() {
    local load_balancer_name=$1
    local port=$2
    local load_balancer_arn
    load_balancer_arn=$(get_load_balancer_arn "$load_balancer_name")
    aws elbv2 describe-listeners --load-balancer-arn "$load_balancer_arn" --query "Listeners[?Port==\`$port\`].ListenerArn" --output text
}

# get task definition revision number function
# takes task definition name as argument
get_task_definition_revision_number() {
    local task_definition_name=$1
    aws ecs describe-task-definition --task-definition "$task_definition_name" --query "taskDefinition.revision" --output text
}

# get iam role arn function
# takes role name as argument
get_iam_role_arn() {
    local role_name=$1
    aws iam get-role --role-name "$role_name" --query "Role.Arn" --output text
}

# get region function
get_region() {
    aws configure get region
}