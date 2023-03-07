#!/bin/sh
set -e

SERVER_HOST_IP="__SERVER_HOST_IP__"
VIRTUAL_PORT="__VIRTUAL_PORT__"

# Run command with node if the first argument contains a "-" or is not a system command. The last
# part inside the "{}" is a workaround for the following bug in ash/dash:
# https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=874264
if [ "${1#-}" != "${1}" ] || [ -z "$(command -v "${1}")" ] || { [ -f "${1}" ] && ! [ -x "${1}" ]; }; then
  if [ "${1}" = "theme" ] && [ "${2}" = "dev" ]; then
    set -- shopify "$@" --host=${SERVER_HOST_IP} --port=${VIRTUAL_PORT}
  else
    set -- shopify "$@"
  fi
fi

exec "$@"
