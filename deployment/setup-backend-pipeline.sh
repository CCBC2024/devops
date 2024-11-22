# Description: This script is used to setup the backend pipeline for charity donation application.

# import the common functions
source ./charity-donation-deployment/common.sh

# import the variables
source ./charity-donation-deployment/variables.sh

# Disable pager for aws cli output to avoid manual intervention for large outputs.
# It is make sure the script runs without interruption
export AWS_PAGER=""

# Define variables
pipeline_role_arn=$(get_iam_role_arn "$pipeline_role_name")
region=$(get_region)

# Step 1: Create the S3 bucket
s3_bucket_name=$(generate_unique_s3_bucket_name "$backend_pipeline_bucket_name")
create_s3_bucket "$s3_bucket_name"

# Step 2: Generate the charity donation backend pipeline
sed -e "s|<pipeline-role-arn>|$pipeline_role_arn|g" \
    -e "s|<s3-bucket-name>|$s3_bucket_name|g" \
    -e "s|<region>|$region|g" \
    -e "s|<code-deploy-application-name>|$code_deploy_application_name|g" \
    -e "s|<code-deploy-deployment-group-name>|$backend_deployment_group_name|g" \
    -e "s|<task-definition-template-path>|$backend_task_definition_pipeline_path|g" \
    -e "s|<appspec-template-path>|$backend_appspec_pipeline_path|g" \
    -e "s|<pipeline-name>|$backend_source_code|g" \
    -e "s|<deployment-repository-name>|$deployment_source_code|g" \
    -e "s|<ecr-repository-name>|$backend_source_code|g" \
    "$pipeline_template_path" > "$backend_pipeline_path"

echo "Updated charity donation JSON saved to $backend_pipeline_path"

# create pipeline
create_code_pipeline "$backend_source_code" "$backend_pipeline_path"