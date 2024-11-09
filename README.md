# DevOps

## Stage 2:

To prepare for this stage, we need to have the following resources:
We are using the CI/CD lab for this stage: https://awsacademy.instructure.com/courses/92321/modules/items/8491173

We first create the Cloud9 environment as task 1.3 in the previous stage.
With the following settings:
- Name: charityDonationIDE
- Instance type: t3.small
- Platform: Amazon Linux
- Network settings: 
  - VPC: LabVPC, 
  - Subnet: Public Subnet1 
  - Connection: SSH

Then upload the project file to the Cloud9 environment, which named `charity-donation-application.zip`.
Unzip the file after uploading by running the following command:
```bash
unzip charity-donation-application.zip
```
### Task 2.1: Migrate the application code to CodeCommit.
#### Backend (Node.js)
Create a new repository in CodeCommit named `charity-donation-backend`.
Then, push the backend code to the repository.
```bash
cd /home/ec2-user/environment/charity-donation-application
sh ./setup-backend-repository.sh
```

The charity-donation-backend repository is created in CodeCommit.
![img.png](images/img.png)

The source code is pushed to the repository.
![img_1.png](images/img_1.png)

The repository and source code is available in CodeCommit.
![img_2.png](images/img_2.png)

#### Frontend (React)
Create a new repository in CodeCommit named `charity-donation-frontend`.
Then, push the frontend code to the repository.
```bash
cd /home/ec2-user/environment/charity-donation-application
sh ./setup-frontend-repository.sh
```

### Task 2.2: Containerize the application using docker images in the Cloud9 environment.
#### Backend (Node.js)
Build the docker image for the backend application.
```bash
cd /home/ec2-user/environment/charity-donation-application/
sh ./build-backend-docker-image.sh
```

The docker image is built successfully.
![img_3.png](images/img_3.png)

#### Frontend (React)
Build the docker image for the frontend application.
```bash
cd /home/ec2-user/environment/charity-donation-application/
sh ./build-frontend-docker-image.sh
```

### Task 2.3: Push the docker images to the ECR.
#### Backend (Node.js)

Create a new repository in ECR named `charity-donation-backend`.
Then, push the backend docker image to the repository.
```bash
cd /home/ec2-user/environment/charity-donation-application/
sh ./create-backend-ecr-repository.sh
```

The charity-donation-backend repository is created in terminal.
![img_4.png](images/img_4.png)

The charity-donation-backend repository is created in ECR.
![img_5.png](images/img_5.png)


Push the backend docker image to the repository.
```bash
sh ./push-backend-image-to-ecr.sh
```

The backend docker image is pushed to the repository in terminal.
![img_6.png](images/img_6.png)

The backend docker image is pushed to the repository in ECR.
![img_7.png](images/img_7.png)

#### Frontend (React)

Create a new repository in ECR named `charity-donation-frontend`.
Then, push the frontend docker image to the repository.
```bash
cd /home/ec2-user/environment/charity-donation-application/
sh ./create-frontend-ecr-repository.sh
```

Push the frontend docker image to the repository.
```bash
sh ./push-frontend-image-to-ecr.sh
```

### Conclusion
In this second implementation stage, we successfully migrated the application code to CodeCommit, containerized the application using docker images in the Cloud9 environment, and pushed the docker images to the ECR. The backend and frontend applications are now available in the ECR repositories.
In the next stage, we are going to set up the ECS cluster for deployment. It involves creating the ECS cluster, task definition, and service for the backend and frontend applications.



