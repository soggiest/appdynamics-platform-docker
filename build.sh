#! /bin/bash

# This script is provided for illustration purposes only.
#
# To build these Docker containers, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics Controller and EUM Server (64-bit Linux)
#    (https://download.appdynamics.com)

cleanUp() {
  # Clean controller-install build directory
  (cd controller-install; rm controller_64bit_linux.sh euem-64bit-linux.sh response.varfile eum.varfile eum.properties install-appdynamics.sh start-appdynamics.sh stop-appdynamics.sh setup-events-service.sh setup-eum-varfile.sh eum-events-service.varfile .bash_profile)

  if [ -f controller-install/license.lic ]; then
    rm controller-install/license.lic
  fi

  # Clean controller build directory
  (cd controller; rm start-appdynamics.sh stop-appdynamics.sh .bash_profile)

  # Cleanup temp dir and files
  rm -rf .appdynamics
  rm -f cookies.txt index.html*

  # Remove dangling images left-over from build
  if [[ `docker images -q --filter "dangling=true"` ]] 
  then
    echo
    echo "Deleting intermediate containers..."
    docker images -q --filter "dangling=true" | xargs docker rmi -f;
  fi
}
trap cleanUp EXIT

copyInstallerFiles() {
  # Copy installation files and scripts to build installer image
  cp .appdynamics/controller_64bit_linux.sh controller-install
  cp .appdynamics/euem-64bit-linux.sh controller-install
  cp response.varfile controller-install
  cp eum.varfile controller-install
  cp eum.properties controller-install
  cp setup-events-service.sh controller-install
  cp setup-eum-varfile.sh controller-install
  cp eum-events-service.varfile controller-install
  cp install-appdynamics.sh controller-install
  cp start-appdynamics.sh controller-install
  cp stop-appdynamics.sh controller-install
  cp .bash_profile controller-install
}

copyControllerScripts() {
  # Copy scripts to build controller image
  cp start-appdynamics.sh controller
  cp stop-appdynamics.sh controller
  cp .bash_profile controller
}

# Add license file to controller-install build, if supplied
checkLicenseFile() {
  if [ -f license.lic ]; then
    cp license.lic controller-install
    echo "Copied license file to controller-install build dir"
  else
    echo "License file not found - building without embedded license"
  fi
}

promptForInstaller() {
  read -e -p "Enter path to Controller Installer: " CONTROLLER_INSTALL
  cp ${CONTROLLER_INSTALL} .appdynamics/controller_64bit_linux.sh
  read -e -p "Enter path to EUM Server Installer: " EUM_INSTALL
  cp ${EUM_INSTALL} .appdynamics/euem-64bit-linux.sh
}

downloadInstallers() {
  echo "An AppDynamics Portal login is required to download the installer software"
  echo "Email ID/UserName: "
  read USER_NAME

  stty -echo
  echo "Password: "
  read PASSWORD
  stty echo
  echo

  if [ "$USER_NAME" != "" ] && [ "$PASSWORD" != "" ];
  then
    wget --quiet --save-cookies cookies.txt  --post-data "username=$USER_NAME&password=$PASSWORD" --no-check-certificate https://login.appdynamics.com/sso/login/
    SSO_SESSIONID=`grep "sso-sessionid" cookies.txt`
    if [ ! "$SSO_SESSIONID" ]; then
      echo "Incorrect Login/Password"
      exit
    fi

    echo "Downloading AppDynamics Controller..."
    wget --quiet --load-cookies cookies.txt https://download.appdynamics.com/onpremise/public/latest/controller_64bit_linux.sh -O .appdynamics/controller_64bit_linux.sh
    if [ $? -ne 0 ]; then
      exit 
    fi
    CONTROLLER_INSTALL=".appdynamics/controller_64bit_linux.sh"

    echo "Downloading EUEM Installer..."
    wget --quiet --load-cookies cookies.txt https://download.appdynamics.com/onpremise/public/latest/euem-64bit-linux.sh -O .appdynamics/euem-64bit-linux.sh
    if [ $? -ne 0 ]; then
      exit 
    fi
    EUM_INSTALL=".appdynamics/euem-64bit-linux.sh"

  else
    echo "Username or Password missing"
  fi
}

# Build data container
buildDataContainer() {
  echo
  echo "Building Data Volume Container (appdynamics/controller-data)"
  echo
  (cd controller-data; docker build --no-cache -t appdynamics/controller-data .)
}

# Build installer container 
buildInstallContainer() {
  echo
  echo "Building Controller Installation container (appdynamics/controller-install)"
  echo 
  (cd controller-install; docker build --no-cache -t appdynamics/controller-install .)
}

# Build controller container
buildControllerContainer() {
  echo
  echo "Building Controller Runtime container (appdynamics/controller)"
  echo
  (cd controller; docker build --no-cache -t appdynamics/controller .)
}

# Temp dir for installers
mkdir -p .appdynamics

# Prompt for location of Controller and EUEM Installers if called without arguments
if  [ $# -eq 0 ]
then
  promptForInstallers
else
  # Download Controller and EUEM Installers from download.appdynamics.com
  # Requires an AppDynamics portal login: prompt user for email/password
  if [[ $1 == *--download* ]]
  then
    downloadInstallers
  else

    # Allow user to specify locations of Controller and EUEM Installers
    while getopts "c:e:" opt; do
      case $opt in
        c)
          CONTROLLER_INSTALL=$OPTARG
          if [ ! -e ${CONTROLLER_INSTALL} ]
          then
            echo "Not found: ${CONTROLLER_INSTALL}"
            exit
          fi
          cp ${CONTROLLER_INSTALL} .appdynamics/controller_64bit_linux.sh
          ;;
        e)
          EUM_INSTALL=$OPTARG
          if [ ! -e ${EUM_INSTALL} ]
          then
            echo "Not found: ${EUM_INSTALL}"
            exit
          fi
          cp ${EUM_INSTALL} .appdynamics/euem-64bit-linux.sh
          ;;
        \?)
          echo "Invalid option: -$OPTARG"
	  exit
          ;;
      esac
    done
  fi
fi

checkLicenseFile
copyInstallerFiles
copyControllerScripts
buildDataContainer
buildInstallContainer
buildControllerContainer
