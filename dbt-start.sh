#!/bin/bash

# Define the name for the container
CONTAINER_NAME="pontera-dbt"

# You can find all possible image tags in 
# https://github.com/orgs/dbt-labs/packages?visibility=public
DBT_IMAGE="ghcr.io/dbt-labs/dbt-snowflake:1.8.2"

# Default mount path
DEFAULT_PROFILES_PATH="profiles.yml"
# Default dbt project path
PROJECT_PATH=$(pwd)
REST_OF_COMMAND=""

export DOCKER_CLI_HINTS=false

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --profiles)
            DEFAULT_PROFILES_PATH="${2:-$DEFAULT_MOUNT_PATH}"
            shift 2
            ;;
        --project)
            PROJECT_PATH="$PWD/${2:-$PROJECT_PATH}"
            if [ ! -d "$PROJECT_PATH" ]; then
                echo "Error: '$PROJECT_PATH' is not a directory or does not exist."
                exit 1
            fi
            shift 2
            ;;
        *)
            REST_OF_COMMAND+="$1 "
            shift
            ;;
    esac
done

PROFILES_PATH="$PWD/${DEFAULT_PROFILES_PATH}"

if [ ! -f "$PROFILES_PATH" ]; then
    echo "Error: '$PROFILES_PATH' is not a file or does not exist."
    exit 1
fi

echo
echo "Starting DBT container"
echo "Loading project from: $PROJECT_PATH"
echo "Using Profiles file: $PROFILES_PATH"
echo "Command: dbt $REST_OF_COMMAND"
echo

# set -x

 # Check if the container exists
EXISTING_CONTAINER=$(docker ps -a --filter "name=$CONTAINER_NAME" --format '{{.Names}}')

echo "Existing container: $EXISTING_CONTAINER"

FULL_COMMAND="dbt $REST_OF_COMMAND"
if [[ "$EXISTING_CONTAINER" == "$CONTAINER_NAME" ]]; then
    # Check if the container is running
    RUNNING_CONTAINER=$(docker ps --filter "name=$CONTAINER_NAME" --format '{{.Names}}')
    if [[ "$RUNNING_CONTAINER" == "$CONTAINER_NAME" ]]; then
        echo "Container $CONTAINER_NAME is running. Using docker exec."
        docker exec -it "$CONTAINER_NAME" $FULL_COMMAND
    else
        echo "Container $CONTAINER_NAME exists but is stopped. Starting the container."
        docker start "$CONTAINER_NAME"
        docker exec -it "$CONTAINER_NAME" $FULL_COMMAND
    fi
else
    echo "Container $CONTAINER_NAME does not exist. Using docker run."
    docker run -it \
    --name $CONTAINER_NAME \
    --network=host \
    --entrypoint /bin/bash \
    --workdir /usr/app \
    -v $PROFILES_PATH:/root/.dbt/profiles.yml \
    -v $PROJECT_PATH:/usr/app \
    -e DBT_PROFILES_DIR=/root/.dbt \
    -d $DBT_IMAGE
    docker start "$CONTAINER_NAME"
    docker exec -it "$CONTAINER_NAME" $FULL_COMMAND
fi

# # Check if the container exists
# if [[ $(docker ps -a --filter "name=$CONTAINER_NAME" --format '{{.Names}}') == $CONTAINER_NAME ]]; then
#     docker exec -it "$CONTAINER_NAME" $REST_OF_COMMAND
# else
#     # Start the container and open a shell
#     docker run -it \
#     --name $CONTAINER_NAME \
#     --network=host \
#     --workdir /usr/app \
#     -v $PROFILES_PATH:/root/.dbt/profiles.yml \
#     -v $PROJECT_PATH:/usr/app \
#     -e DBT_PROFILES_DIR=/root/.dbt \
#     $DBT_IMAGE $REST_OF_COMMAND
# fi

