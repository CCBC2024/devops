# setup backend auto build

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# setup git pre commit hook for build docker image
setup_git_pre_commit_hook "$backend_directory" "$backend_git_pre_commit_hook_path"

# setup git pre push hook for push docker image to ecr
setup_git_pre_push_hook "$backend_directory" "$backend_git_pre_push_hook_path"
