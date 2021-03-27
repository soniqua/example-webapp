# Build an image from a provided Dockerfile

set -e

build_folder=$1
tag=$2
aws_ecr_repo=$3
profile=$4
region=$5
account=$6

# Login to ECR:

DOCKER_PASSWORD=$(aws ecr get-login-password --profile $profile --region $region)
docker login --username AWS --password $DOCKER_PASSWORD "$account.dkr.ecr.$region.amazonaws.com"

# Build the image
docker build -t "$aws_ecr_repo:$tag" $build_folder

# Push the image
docker push "$aws_ecr_repo:$tag"
