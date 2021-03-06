#!/bin/bash -Eeu

# - - - - - - - - - - - - - - - - - - - - - - - -
image_sha()
{
  echo "$(cd "${ROOT_DIR}" && git rev-parse HEAD)"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
image_tag()
{
  local -r sha="$(image_sha)"
  echo "${sha:0:7}"
}

# - - - - - - - - - - - - - - - - - - - - - - - -
versioner_env_vars()
{
  docker run --rm cyberdojo/versioner
  echo CYBER_DOJO_HOME_SHA="$(image_sha)"
  echo CYBER_DOJO_HOME_TAG="$(image_tag)"
  echo CYBER_DOJO_HOME_CLIENT_IMAGE=cyberdojo/home-client
  echo CYBER_DOJO_HOME_CLIENT_PORT=9999
  echo CYBER_DOJO_HOME_SERVER_USER=nobody
  echo CYBER_DOJO_HOME_CLIENT_USER=nobody
}
