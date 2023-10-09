#!/usr/bin/env bash
set -e

if [[ -z "$HOST_UID" ]]; then
    echo "ERROR: please set HOST_UID" >&2
    exit 1
fi
if [[ -z "$HOST_GID" ]]; then
    echo "ERROR: please set HOST_GID" >&2
    exit 1
fi

# Use this code if you want to modify an existing user account:
groupmod --gid "$HOST_GID" gnuradio
usermod --uid "$HOST_UID" gnuradio

# Drop privileges and execute next container command, or 'bash' if not specified.
if [[ $# -gt 0 ]]; then
    exec sudo --preserve-env=TERM -H -u gnuradio -- "$@"
else
    exec sudo --preserve-env=TERM -H -u gnuradio -- bash
fi
exec "$@"
