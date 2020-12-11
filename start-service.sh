#!/bin/bash -xe

# Start the node application
. /home/ec2-user/.bash_profile
cd /home/ec2-user/app/release
npm run start
