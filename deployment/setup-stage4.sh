# setup all scripts in the stage 3

sh ./charity-donation-deployment/setup-codedeploy.sh
sh ./charity-donation-deployment/setup-deployment-repository.sh
sh ./charity-donation-deployment/setup-backend-pipeline.sh
sh ./charity-donation-deployment/setup-frontend-pipeline.sh
sh ./charity-donation-deployment/setup-frontend-auto-build.sh
sh ./charity-donation-deployment/setup-backend-auto-build.sh