#! /bin/bash

APPD_INSTALL_DIR="/appdynamics"

$APPD_INSTALL_DIR/Controller/bin/modifyJvmOptions.sh delete '-Dappdynamics.controller.eum.analytics.service.hostName=analytics.api.appdynamics.com'
$APPD_INSTALL_DIR/Controller/bin/modifyJvmOptions.sh add '-Dappdynamics.controller.eum.analytics.service.hostName=localhost:9080'
$APPD_INSTALL_DIR/Controller/bin/modifyJvmOptions.sh list
