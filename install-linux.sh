#!/usr/bin/env bash
set -e

get-release(){
  FASTPASS_VERSION=${VERSION-latest}
  FASTPASS_RELEASES_URL="https://api.github.com/repos/jwaldrip/fastpass/releases/${FASTPASS_VERSION}"
  if [ -n "${GITHUB_API_TOKEN}" ] ; then
    curl -fsSL -H "Authorization: token ${GITHUB_API_TOKEN}" ${FASTPASS_RELEASES_URL}
  else
    curl -fsSL ${FASTPASS_RELEASES_URL}
  fi
}

get-download-url(){
  jq -r '.assets[] | select(.name | contains("linux")).browser_download_url'
}

# Install Psykube
curl -fsSL `get-release | get-download-url` | sudo tar -xzC /usr/local/bin
