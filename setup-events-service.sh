#!/bin/bash

PORT=3388
USER=controller
PASS=controller
DB=controller

CONTROLLER_HOME="/appdynamics/Controller"
MY_SQL_HOME=$CONTROLLER_HOME/db/bin

function execMySQL {
	echo "$1" | ${MY_SQL_HOME}/mysql --port=$PORT -u $USER --password=$PASS --database=$DB | tail -1
}

SELECT_QUERY_LOCAL_KEY="SELECT value FROM controller.global_configuration_cluster WHERE name='appdynamics.analytics.local.store.controller.key';"
ANALYTICS_LOCAL_STORE_KEY=$(execMySQL "$SELECT_QUERY_LOCAL_KEY" | awk '{print $1}')
echo "appdynamics.analytics.local.store.controller.key: $ANALYTICS_LOCAL_STORE_KEY"

SELECT_QUERY_SERVER_KEY="SELECT value FROM controller.global_configuration_cluster WHERE name='appdynamics.analytics.server.store.controller.key';"
ANALYTICS_SERVER_STORE_KEY=$(execMySQL "$SELECT_QUERY_SERVER_KEY" | awk '{print $1}')
echo "appdynamics.analytics.server.store.controller.key: $ANALYTICS_SERVER_STORE_KEY"

UPDATE_QUERY_SERVER_KEY="UPDATE controller.global_configuration_cluster SET value='$ANALYTICS_LOCAL_STORE_KEY' WHERE name='appdynamics.analytics.server.store.controller.key';"
echo $UPDATE_QUERY_SERVER_KEY
execMySQL "$UPDATE_QUERY_SERVER_KEY"
