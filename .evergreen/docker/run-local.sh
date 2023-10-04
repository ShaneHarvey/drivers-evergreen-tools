#!/usr/bin/env bash
#
# Run a local MongoDB orchestration inside a docker container
#
set -eu

NAME=drivers-evergreen-tools
ENTRYPOINT=${ENTRYPOINT:-/root/local-entrypoint.sh}
IMAGE=${TARGET_IMAGE:-ubuntu20.04}
PLATFORM=${DOCKER_PLATFORM:-}
# e.g. --platform linux/amd64

docker build $PLATFORM -t $NAME $IMAGE
cd ../..

AUTH=${AUTH:-noauth}
SSL=${SSL:-nossl}
TOPOLOGY=${TOPOLOGY:-server}
LOAD_BALANCER=${LOAD_BALANCER:-}
STORAGE_ENGINE=${STORAGE_ENGINE:-}
REQUIRE_API_VERSION=${REQUIRE_API_VERSION:-}
DISABLE_TEST_COMMANDS=${DISABLE_TEST_COMMANDS:-}
MONGODB_VERSION=${MONGODB_VERSION:-latest}
MONGODB_DOWNLOAD_URL=${MONGODB_DOWNLOAD_URL:-}
ORCHESTRATION_FILE=${ORCHESTRATION_FILE:-basic.json}

ENV="-e MONGODB_VERSION=$MONGODB_VERSION"
ENV+=" -e TOPOLOGY=$TOPOLOGY"
ENV+=" -e AUTH=$AUTH"
ENV+=" -e SSL=$SSL"
ENV+=" -e ORCHESTRATION_FILE=$ORCHESTRATION_FILE"
ENV+=" -e LOAD_BALANCER=$LOAD_BALANCER"
ENV+=" -e STORAGE_ENGINE=$STORAGE_ENGINE"
ENV+=" -e REQUIRE_API_VERSION=$REQUIRE_API_VERSION"
ENV+=" -e DISABLE_TEST_COMMANDS=$DISABLE_TEST_COMMANDS"
ENV+=" -e MONGODB_DOWNLOAD_URL=$MONGODB_DOWNLOAD_URL"

if [ "$TOPOLOGY" == "server" ]; then
    PORT="-p 27017:2017"
else
    PORT="-p 27017:2017 -p 27018:2018 -p 27019:2019"
fi
USE_TTY=""
test -t 1 && USE_TTY="-t"
VOL="-v `pwd`:/root/drivers-evergreen-tools"

docker run $PLATFORM --rm $ENV $PORT $VOL -i $USE_TTY $NAME $ENTRYPOINT