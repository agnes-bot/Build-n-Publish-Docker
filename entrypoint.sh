#!/bin/sh
set -e

BRANCH=$(echo ${GITHUB_REF} | sed -e "s/refs\/heads\///g")

if [ "${BRANCH}" == "master" ]; then
  BRANCH="latest"
fi;

# if contains /refs/tags/
if [ $(echo ${GITHUB_REF} | sed -e "s/refs\/tags\///g") != ${GITHUB_REF} ]; then
  BRANCH="latest"
fi;

echo ${INPUT_PASSWORD} | docker login -u ${INPUT_USERNAME} --password-stdin ${INPUT_REGISTRY}

DOCKERNAME="${INPUT_NAME}:${BRANCH}"
BUILDPARAMS="${INPUT_EXTRA_BUILD_PARAMS}"

if [ ! -z "${INPUT_DOCKERFILE}" ]; then
  BUILDPARAMS="$BUILDPARAMS -f ${INPUT_DOCKERFILE}"
fi

if [ ! -z "${INPUT_CACHE}" ]; then
  docker pull ${DOCKERNAME}
  BUILDPARAMS="$BUILDPARAMS --cache-from ${DOCKERNAME}"
fi


DOCKER_TAG=$(echo ${GITHUB_REF} | sed -e 's/refs\/tags\/v//')
docker build $BUILDPARAMS -t ${DOCKERNAME} .
docker push ${DOCKERNAME}

docker logout
