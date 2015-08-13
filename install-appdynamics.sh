#!/bin/bash

echo
echo "Preparing AppDynamics platform installation"
echo "*******************************************"
echo

# Use container hostname for response files
echo "Setting hostname in response varfiles"
sed -e "s/SERVERHOSTNAME/`hostname`/g" /install/response.varfile > /install/response.varfile.1
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
	echo 'docker run --rm -it --volumes-from controller-data -v $(pwd)/:/license appdynamics/controller-install bash -c "cp /license/license.lic /appdynamics/Controller"'
        read -rsp $'Press any key to continue or CTRL+C to exit\n' -n1 key
fi

# Change license file ownership and permissions
echo "Setting license file ownership and permission"
chown appdynamics:appdynamics /appdynamics/Controller/license.lic
chmod 744 /appdynamics/Controller/license.lic

echo
echo "Installing controller"
echo "*********************"
echo
 
# Run Controller install
chown appdynamics:appdynamics /install/controller_64bit_linux.sh
chmod 774 /install/controller_64bit_linux.sh
su - appdynamics -c '/install/controller_64bit_linux.sh -q -varfile /install/response.varfile.1'

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
su - appdynamics -c 'cat /install/eum-events-service.varfile >> /install/eum.varfile.1'

# Start embedded Events Service
echo "Starting embedded Events Service"
su - appdynamics -c "$APPD_INSTALL_DIR/Controller/bin/controller.sh start-events-service"

echo
echo "Installing End User Monitoring"
echo "******************************"
echo

# Run EUEM install
su - appdynamics -c "cat /install/euem.varfile.1"
chown appdynamics:appdynamics /install/euem-64bit-linux.sh
chmod 774 /install/euem-64bit-linux.sh

su - appdynamics -c '/install/euem-64bit-linux.sh -q -varfile /install/eum.varfile.1'

echo
echo "Stopping AppDynamics Platform"
echo "*****************************"
echo

# Stop Controller, EUEM and Analytics
su - appdynamics -c '/appdynamics/Controller/bin/stopController.sh'

echo
echo "Installed AppDynamics Platform"
echo "******************************"
echo