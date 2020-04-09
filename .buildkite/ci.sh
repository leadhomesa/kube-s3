#!/bin/bash

# Repo specific config
# This is where the built docker image will be pushed to
export APP=kube-s3

export DOCKER_REPO=leadhomesa/${APP}

# Init
set -euo pipefail

# Change current branch since git is currently a detached HEAD. This is required for gitversion to work
# git fetch
git checkout -B ${BUILDKITE_BRANCH}
git reset --hard
# git branch --set-upstream-to=origin/${BUILDKITE_BRANCH} ${BUILDKITE_BRANCH}
# git pull

# Run gitversion, mounting the repo root folder. Export the result as BUILD_NUMBER
export BUILD_NUMBER=$(docker run -v $(pwd):/repo gittools/gitversion:5.0.0-beta2-21-linux /repo | jq -r ".LegacySemVer")

export DOCKER_TAG=${DOCKER_REPO}:${BUILD_NUMBER}
echo "+++ :package: Building version ${DOCKER_TAG}"

# Build docker image
docker build -t ${DOCKER_TAG} . --build-arg APP=${APP} --build-arg VERSION=${BUILD_NUMBER}

# Upload docker image
docker push ${DOCKER_TAG}