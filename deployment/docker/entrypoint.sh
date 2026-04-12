#!/bin/bash
#
# Entrypoint Bash script for the AudioMuse-AI Docker container.
#
#
# This script performs the following tasks:
# 1. Sets the timezone based on the TZ environment variable (if provided).
# 2. Starts the appropriate service (web or worker) based on the SERVICE_TYPE environment variable.

# Set strict mode for better error handling
# -e: Exit immediately if a command exits with a non-zero status.
# -u: Treat unset variables as an error and exit immediately.
# -o pipefail: Return the exit status of the last command in the pipeline that failed.
set -euo pipefail

# Set timezone if TZ environment variable is provided
if [[ -n "${TZ:-}" ]]; then
  if [[ -f "/usr/share/zoneinfo/$TZ" ]]; then
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime
    printf '%s\n' "$TZ" >/etc/timezone
  else
    printf "Warning: timezone '%s' not found in /usr/share/zoneinfo\n" "$TZ" >&2
  fi
fi

# Start the appropriate service based on SERVICE_TYPE environment variable
if [[ "${SERVICE_TYPE:-flask}" == "worker" ]]; then
  echo "Starting worker processes via supervisord..."
  exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
else
  echo "Starting web service..."
  exec gunicorn --bind 0.0.0.0:8000 --workers 1 --timeout 300 app:app
fi
