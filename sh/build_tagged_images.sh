#!/bin/bash -Eeu

source ${SH_DIR}/augmented_docker_compose.sh

# - - - - - - - - - - - - - - - - - - - - - -
build_tagged_images()
{
  local -r dil=$(docker image ls --format "{{.Repository}}:{{.Tag}}")
  remove_all_but_latest "${dil}" "${CYBER_DOJO_HOME_CLIENT_IMAGE}"
  remove_all_but_latest "${dil}" "${CYBER_DOJO_HOME_IMAGE}"

  augmented_docker_compose \
    build \
    --build-arg COMMIT_SHA=$(git_commit_sha)

  docker tag ${CYBER_DOJO_HOME_IMAGE}:$(image_tag) ${CYBER_DOJO_HOME_IMAGE}:latest
  docker tag ${CYBER_DOJO_HOME_CLIENT_IMAGE}:$(image_tag) ${CYBER_DOJO_HOME_CLIENT_IMAGE}:latest

  check_embedded_env_var
  echo
  echo "CYBER_DOJO_HOME_TAG=${CYBER_DOJO_HOME_TAG}"
  echo "CYBER_DOJO_HOME_SHA=${CYBER_DOJO_HOME_SHA}"
  echo
}

# - - - - - - - - - - - - - - - - - - - - - -
remove_all_but_latest()
{
  local -r docker_image_ls="${1}"
  local -r name="${2}"
  for image_name in `echo "${docker_image_ls}" | grep "${name}:"`
  do
    if [ "${image_name}" != "${name}:latest" ]; then
      if [ "${image_name}" != "${name}:<none>" ]; then
        docker image rm "${image_name}"
      fi
    fi
  done
}

# - - - - - - - - - - - - - - - - - - - - - -
check_embedded_env_var()
{
  if [ "$(git_commit_sha)" != "$(sha_in_image)" ]; then
    echo "ERROR: unexpected env-var inside image $(image_name):$(image_tag)"
    echo "expected: 'SHA=$(git_commit_sha)'"
    echo "  actual: 'SHA=$(sha_in_image)'"
    exit 42
  fi
}

# - - - - - - - - - - - - - - - - - - - - - -
git_commit_sha()
{
  echo $(cd "${SH_DIR}" && git rev-parse HEAD)
}

# - - - - - - - - - - - - - - - - - - - - - -
image_name()
{
  echo "${CYBER_DOJO_HOME_IMAGE}"
}

# - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  echo "${CYBER_DOJO_HOME_TAG}"
}

# - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  echo "${CYBER_DOJO_HOME_SHA}"
}

# - - - - - - - - - - - - - - - - - - - - - -
sha_in_image()
{
  docker run --rm $(image_name):$(image_tag) sh -c 'echo -n ${SHA}'
}
