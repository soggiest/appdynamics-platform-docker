#! /bin/bash

# This script is provided for illustration purposes only.
#
# To build these Docker containers, you will need to download the following components:
# 1. An appropriate version of the Oracle Java 7 JDK
#    (http://www.oracle.com/technetwork/java/javase/downloads/index.html)
# 2. Correct versions for the AppDynamics Controller and EUM Server (64-bit Linux)
#    (https://download.appdynamics.com)

cleanUp() {
  # Clean platform-install build directory
  (cd platform-install; rm controller_64bit_linux.sh \
                           euem-64bit-linux.sh \
                           controller.varfile \
                           eum.varfile \
                           eum.properties \
                           install-appdynamics.sh \
                           start-appdynamics.sh \
                           stop-appdynamics.sh \
                           setup-events-service.sh \
                           setup-eum-varfile.sh \
                           setup-controller-jvmoptions.sh \
                           eum-events-service.varfile \
                           .bash_profile)

  if [ -f platform-install/license.lic ]; then
    rm platform-install/license.lic
  fi

  # Clean platform build directory
  (cd platform; rm start-appdynamics.sh \
                   stop-appdynamics.sh \
                   .bash_profile)

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
  cp .appdynamics/controller_64bit_linux.sh platform-install
  cp .appdynamics/euem-64bit-linux.sh platform-install
  cp controller.varfile platform-install
  cp eum.varfile platform-install
  cp eum.properties platform-install
  cp setup-events-service.sh platform-install
  cp setup-eum-varfile.sh platform-install
  cp setup-controller-jvmoptions.sh platform-install
  cp eum-events-service.varfile platform-install
  cp install-appdynamics.sh platform-install
  cp start-appdynamics.sh platform-install
  cp stop-appdynamics.sh platform-install
  cp .bash_profile platform-install
}

copyControllerScripts() {
  # Copy scripts to build platform image
  cp start-appdynamics.sh platform
  cp stop-appdynamics.sh platform
  cp .bash_profile platform
}

# Add license file to platform-install build, if supplied
checkLicenseFile() {
  if [ -f license.lic ]; then
    cp license.lic platform-install
    echo "Copied license file to platform-install build dir"
  else
    echo "License file not found - building without embedded license"
  fi
}

promptForInstallers() {
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
    wget --quiet --load-cookies cookies.txt https://download.appdynamics.com/onpremise/public/latest/platform_64bit_linux.sh -O .appdynamics/platform_64bit_linux.sh
    if [ $? -ne 0 ]; then
      exit 
    fi
    CONTROLLER_INSTALL=".appdynamics/platform_64bit_linux.sh"

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
  echo "Building Data Volume Container (appdynamics/platform-data)"
  echo
  (cd platform-data; docker build --no-cache -t appdynamics/platform-data .)
}

# Build installer container 
buildInstallContainer() {
  echo
  echo "Building Controller Installation container (appdynamics/platform-install)"
  echo 
  (cd platform-install; docker build --no-cache -t appdynamics/platform-install .)
}

# Build platform container
buildControllerContainer() {
  echo
  echo "Building Controller Runtime container (appdynamics/platform)"
  echo
  (cd platform; docker build --no-cache -t appdynamics/platform .)
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
