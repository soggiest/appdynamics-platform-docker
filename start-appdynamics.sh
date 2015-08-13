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
