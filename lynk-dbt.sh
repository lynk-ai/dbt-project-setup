#!/bin/bash

# Define the name for the container
CONTAINER_NAME="lynk-dbt"

# You can find all possible image tags in 
# https://github.com/orgs/dbt-labs/packages?visibility=public
DBT_IMAGE="ghcr.io/dbt-labs/dbt-snowflake:1.7.3"

# Default mount path
DEFAULT_PROFILES_PATH="profiles.yml"
# Default dbt project path
PROJECT_PATH=$(pwd)

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
            echo "Unknown parameter passed: $1"
            exit 1
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
echo

# Start the container and open a shell
docker run -it \
  --rm \
  --name $CONTAINER_NAME \
  --network=host \
  --entrypoint /bin/bash \
  --workdir /usr/app \
  -v $PROFILES_PATH:/root/.dbt/profiles.yml \
  -v $PROJECT_PATH:/usr/app \
  -e DBT_PROFILES_DIR=/root/.dbt \
  $DBT_IMAGE