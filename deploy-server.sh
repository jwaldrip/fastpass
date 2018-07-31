#!/usr/bin/bash
set -e

echo $KUBECONFIG_ENCODED | base64 - > /tmp/kubeconfig
curl -fsSL https://raw.githubusercontent.com/psykube/psykube/master/travis.sh | bash
psykube apply
