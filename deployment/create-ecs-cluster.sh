# create ecs cluster

# import variables
source ./charity-donation-deployment/variables.sh

# import common functions
source ./charity-donation-deployment/common.sh

# create ecs cluster
create_ecs_cluster $ecs_cluster_name