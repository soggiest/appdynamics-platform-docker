#!/bin/bash

# This script is provided for illustration purposes only.
#
# To build these Docker containers, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics Controller and EUM Server (64-bit Linux)
#    (https://download.appdynamics.com)

echo "Stopping AppDynamics Controller"
echo "*******************************"
echo
su - appdynamics -c '/appdynamics/Controller/bin/stopController.sh'
echo
echo "Stopping EUM Server"
echo "*******************"
echo
su - appdynamics -c '(cd /appdynamics/EUM/eum-processor; ./bin/eum.sh stop)'
echo
echo "AppDynamics Platform shutdown completed: it is safe to stop this container"
echo "**************************************************************************"
