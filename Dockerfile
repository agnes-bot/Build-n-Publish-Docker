FROM docker:19.03.1 as runtime
LABEL "com.github.actions.name"="Build&Publish Docker"
LABEL "com.github.actions.description"="Uses the git branch as the docker tag and pushes the container"
LABEL "com.github.actions.icon"="anchor"
LABEL "com.github.actions.color"="blue"

LABEL "repository"="https://github.com/agnes-bot/Build-n-Publish-Docker/"
LABEL "maintainer"="Rotinov Egor"

RUN apk update \
  && apk upgrade \
  && apk add --no-cache git \
  && apk add --no-cache curl

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

FROM runtime
