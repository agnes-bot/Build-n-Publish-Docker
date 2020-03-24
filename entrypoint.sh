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


DOCKER_TAG=$(echo ${GITHUB_REF} | sed -e 's/refs\/tags\/v//')
echo ${DOCKERNAME}
docker build $BUILDPARAMS -t ${DOCKERNAME} .
docker run -p 5000:5000 --rm ${DOCKERNAME} python test.py
docker push ${DOCKERNAME}

docker logout

README_FILEPATH="./README.md"

LOGIN_PAYLOAD="{\"username\": \"${INPUT_USERNAME}\", \"password\": \"${INPUT_PASSWORD}\"}"
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d ${LOGIN_PAYLOAD} https://hub.docker.com/v2/users/login/ | jq -r .token)

REPO_URL="https://hub.docker.com/v2/repositories/${INPUT_NAME}/"
RESPONSE_CODE=$(curl -s --write-out %{response_code} --output /dev/null -H "Authorization: JWT ${TOKEN}" -X PATCH --data-urlencode full_description@${README_FILEPATH} ${REPO_URL})
