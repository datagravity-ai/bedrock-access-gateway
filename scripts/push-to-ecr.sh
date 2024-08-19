# Make sure you have created the Repo in AWS ECR in every regions you want to push to before executing this script.
# Usage:
#    cd scripts
#    chmod +x push-to-ecr.sh
#    ./push-to-ecr.sh


# Define variables
IMAGE_NAME="bedrock-access-gateway"
TAG="latest"
AWS_REGIONS=("us-west-1") # List of AWS regions
#AWS_REGIONS=("us-east-1" "us-west-2" "eu-central-1" "ap-southeast-1" "ap-northeast-1") # List of AWS regions

# Build Docker image
docker build --platform linux/amd64 -t $IMAGE_NAME:$TAG -f ../src/Dockerfile_ecs ../src/ 
# docker build --platform linux/amd64 -t $IMAGE_NAME:$TAG ../src/ 

# Loop through each AWS region
for REGION in "${AWS_REGIONS[@]}"
do
    # Get the account ID for the current region
    ACCOUNT_ID=$(aws sts get-caller-identity --region $REGION --query Account --output text)

    # Create repository URI
    REPOSITORY_URI="public.ecr.aws/anomalo/${IMAGE_NAME}"

    # Log in to ECR
    # aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REPOSITORY_URI

    # Tag the image for the current region
    docker tag $IMAGE_NAME:$TAG $REPOSITORY_URI:$TAG

    # Push the image to ECR
    docker push $REPOSITORY_URI:$TAG
    echo "Pushed $IMAGE_NAME:$TAG to $REPOSITORY_URI"
done
