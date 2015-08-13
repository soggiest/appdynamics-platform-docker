FROM appdynamics/base-centos

MAINTAINER Mark Prichard (mark.prichard@appdynamics.com)

RUN mkdir -p /install
RUN chown -R appdynamics:appdynamics /install

# Controller installation and response file
ADD /controller_64bit_linux.sh /install/
ADD /response.varfile /install/

# EUEM installation and response files
ADD /euem-64bit-linux.sh /install/
ADD /eum.varfile /install/
ADD /eum.properties /install/
ADD /.bash_profile /home/appdynamics/
RUN chown appdynamics:appdynamics /install/eum.properties

#Configure EUM response varfile for local ES
ADD /setup-eum-varfile.sh /install/
RUN chown appdynamics:appdynamics /install/setup-eum-varfile.sh
RUN chmod 774 /install/setup-eum-varfile.sh

# Events Service configuration for single-node local ES
ADD /setup-events-service.sh /install/
RUN chown appdynamics:appdynamics /install/setup-events-service.sh
RUN chmod 774 /install/setup-events-service.sh

ADD /eum-events-service.varfile /install/
RUN chown appdynamics:appdynamics /install/eum-events-service.varfile
RUN chmod 774 /install/eum-events-service.varfile

# AppDynamics License File - Uncomment to add to build
# ADD /license.lic /install/

# Add script to initialize AppDynamics
ADD /install-appdynamics.sh /install/
RUN chmod 774 /install/install-appdynamics.sh

# Add script to (re)start AppDynamics
ADD /start-appdynamics.sh /install/
RUN chmod 774 /install/start-appdynamics.sh

# Add script to stop AppDynamics
ADD /stop-appdynamics.sh /install/
RUN chmod 774 /install/stop-appdynamics.sh

# Install AppDynamics Platform and exit - for manual install/upgrade use 'docker run ... controller-install bash'
CMD /install/install-appdynamics.sh

