# This script is provided for illustration purposes only.
#
# To build these Docker containers, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics Controller and EUM Server (64-bit Linux)
#    (https://download.appdynamics.com)

#!/bin/bash

echo "Starting AppDynamics Controller"
echo "*******************************"
echo
su - appdynamics -c '/appdynamics/Controller/bin/startController.sh'
echo
echo "Starting Events Service"
echo "***********************"
echo
su - appdynamics -c '/appdynamics/Controller/bin/controller.sh start-events-service'
echo
echo "Starting EUM Server"
echo "*******************"
echo
su - appdynamics -c '(cd /appdynamics/EUM/eum-processor; ./bin/eum.sh start)'
echo
echo "AppDynamics Platform Started"
echo "****************************"
echo
tail -f /appdynamics/Controller/logs/server.log
