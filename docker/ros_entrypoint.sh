#!/usr/bin/env bash
set -e

source "/opt/ros/${ROS_DISTRO}/setup.bash"

if [ -f "/workspace/devel/setup.bash" ]; then
  source "/workspace/devel/setup.bash"
fi

exec "$@"
