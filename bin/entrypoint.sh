#!/bin/bash

set -e

echo "Initializing Busybox"

# Source the shared library
. "$(dirname "$0")/../lib/validate.sh"

check_var PTAH_SSH_PUBLIC_KEY
check_var PTAH_SSH_PRIVATE_KEY

mkdir -p ~/.ssh
chmod 700 ~/.ssh

cat <<EOF > ~/.ssh/config
Host *
  StrictHostKeyChecking accept-new
EOF

echo "$PTAH_SSH_PUBLIC_KEY" > ~/.ssh/id_rsa.pub
echo "$PTAH_SSH_PRIVATE_KEY" > ~/.ssh/id_rsa

chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub

exec "$@"
