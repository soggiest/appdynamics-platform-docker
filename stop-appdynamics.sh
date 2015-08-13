#!/bin/bash
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
