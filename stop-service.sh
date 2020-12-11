#!/bin/bash -xe

# Stop the node application
. /home/ec2-user/.bash_profile
[ -d "/home/ec2-user/app/release" ] && \
  cd /home/ec2-user/app/release &&
  npm stop
