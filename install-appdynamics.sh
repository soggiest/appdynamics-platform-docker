#!/bin/bash

# This script is provided for illustration purposes only.
#
# To build these Docker containers, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics Controller and EUM Server (64-bit Linux)
#    (https://download.appdynamics.com)

echo
echo "Preparing AppDynamics platform installation"
echo "*******************************************"
echo

# Use container hostname for response files
echo "Setting hostname in response varfiles"
sed -e "s/SERVERHOSTNAME/`hostname`/g" /install/controller.varfile > /install/controller.varfile.1
sed -e "s/SERVERHOSTNAME/`hostname`/g" /install/eum.varfile > /install/eum.varfile.1
chown appdynamics:appdynamics /install/*.varfile.1

# Create controller install directory
export APPD_INSTALL_DIR=/appdynamics
echo "Will install AppDynamics Platform into $APPD_INSTALL_DIR"
mkdir -p $APPD_INSTALL_DIR/Controller
chown appdynamics:appdynamics $APPD_INSTALL_DIR/Controller

# Install or prompt for license file
if [ -f /install/license.lic ]; then
  cp /install/license.lic /appdynamics/Controller/
else
  echo "You must supply a license file for this installation: use a separate terminal to run the following command in the directory containing your license file:"
  echo 'docker run --rm -it --volumes-from platform-data -v $(pwd)/:/license appdynamics/platform-install bash -c "cp /license/license.lic /appdynamics/Controller"'
  read -rsp $'Press any key to continue or CTRL+C to exit\n' -n1 key
fi

if [ -f $APPD_INSTALL_DIR/Controller/license.lic ]; then
  echo "Setting license file ownership and permission"
  chown appdynamics:appdynamics $APPD_INSTALL_DIR/Controller/license.lic
  chmod 744 $APPD_INSTALL_DIR/Controller/license.lic
else
  echo "Could not find $APPD_INSTALL_DIR/Controller/license.lic - exiting"
  exit
fi

echo
echo "Installing Controller"
echo "*********************"
echo
su - appdynamics -c "cat /install/controller.varfile.1"
chown appdynamics:appdynamics /install/controller_64bit_linux.sh
chmod 774 /install/controller_64bit_linux.sh
su - appdynamics -c '/install/controller_64bit_linux.sh -q -varfile /install/controller.varfile.1'

echo
echo "Configuring Events Service"
echo "**************************"
echo

# Setup single-node Events Service
echo "Configuring single-node local Events Service for EUM/Analytics"
su - appdynamics -c '/install/setup-events-service.sh'

# Configure EUM response varfile to use local Events Service
echo "Configuring EUM response varfile"
su - appdynamics -c '/install/setup-eum-varfile.sh'

# Configure EUM to use embedded Events Service
echo "Setting Controller JvmOptions for End User Monitoring"
su - appdynamics -c '/install/setup-controller-jvmoptions.sh'

# Start embedded Events Service
echo "Starting embedded Events Service"
su - appdynamics -c "$APPD_INSTALL_DIR/Controller/bin/controller.sh start-events-service"

echo
echo "Installing End User Monitoring"
echo "******************************"
echo
su - appdynamics -c "cat /install/eum.varfile.1"
chown appdynamics:appdynamics /install/euem-64bit-linux.sh
chmod 774 /install/euem-64bit-linux.sh
su - appdynamics -c '/install/euem-64bit-linux.sh -q -varfile /install/eum.varfile.1'

echo
echo "Stopping AppDynamics Platform"
echo "*****************************"
echo
su - appdynamics -c '/appdynamics/Controller/bin/stopController.sh'

echo
echo "Installed AppDynamics Platform"
echo "******************************"
echo
