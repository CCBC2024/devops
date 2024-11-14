# setup all scripts in the stage 2

# setup backend nodejs
sh ./charity-donation-deployment/setup-backend-repository.sh
sh ./charity-donation-deployment/build-backend-docker-image.sh
sh ./charity-donation-deployment/create-backend-ecr-repository.sh
sh ./charity-donation-deployment/push-backend-image-to-ecr.sh

# setup frontend reactjs
sh ./charity-donation-deployment/setup-frontend-repository.sh
sh ./charity-donation-deployment/build-frontend-docker-image.sh
sh ./charity-donation-deployment/create-frontend-ecr-repository.sh
sh ./charity-donation-deployment/push-frontend-image-to-ecr.sh
