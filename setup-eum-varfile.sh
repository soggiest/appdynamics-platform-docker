#! /bin/bash

export CONTROLLER_HOME="/appdynamics/Controller"
export EUM_KEY_PROPERTY=$(grep "ad.accountmanager.key.eum=" $CONTROLLER_HOME/events_service/conf/events-service-all.properties)
export EUM_KEY=${EUM_KEY_PROPERTY#ad.accountmanager.key.eum=}
echo "ad.accountmanage.key.eum: $EUM_KEY"

echo "eventsService.isEnabled$Boolean=true" >> /install/eum-events-service.varfile
echo "eventsService.serverScheme=http" >> /install/eum-events-service.varfile
echo "eventsService.host=localhost" >> /install/eum-events-service.varfile
echo "eventsService.port=9080" >> /install/eum-events-service.varfile
echo "eventsService.APIKey=$EUM_KEY" >> /install/eum-events-service.varfile
