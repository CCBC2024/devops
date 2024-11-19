# setup all scripts in the stage 3

sh ./charity-donation-deployment/create-ecs-cluster.sh
sh ./charity-donation-deployment/create-target-group.sh
sh ./charity-donation-deployment/setup-sg-lb.sh
sh ./charity-donation-deployment/create-frontend-task-definition.sh
sh ./charity-donation-deployment/create-backend-task-definition.sh
sh ./charity-donation-deployment/create-frontend-ecs-service.sh
sh ./charity-donation-deployment/create-backend-ecs-service.sh