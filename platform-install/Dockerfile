FROM appdynamics/base-centos

MAINTAINER Mark Prichard (mark.prichard@appdynamics.com)

RUN mkdir -p /install

# Controller installation and response file
ADD /controller_64bit_linux.sh /install/
RUN chmod 774 /install/controller_64bit_linux.sh
ADD /controller.varfile /install/

# EUEM installation and response files
ADD /euem-64bit-linux.sh /install/
RUN chmod 774 /install/euem-64bit-linux.sh

ADD /eum.varfile /install/
ADD /.bash_profile /home/appdynamics/

ADD /setup-eum-varfile.sh /install/
RUN chmod 774 /install/setup-eum-varfile.sh

ADD /setup-events-service.sh /install/
RUN chmod 774 /install/setup-events-service.sh

ADD /setup-controller-jvmoptions.sh /install/
RUN chmod 774 /install/setup-controller-jvmoptions.sh

# AppDynamics License File - Uncomment to add to build
# ADD /license.lic /install/

# AppDynamics Platform install/start/stop scripts
ADD /install-appdynamics.sh /install/
RUN chmod 774 /install/install-appdynamics.sh

ADD /start-appdynamics.sh /install/
RUN chmod 774 /install/start-appdynamics.sh

ADD /stop-appdynamics.sh /install/
RUN chmod 774 /install/stop-appdynamics.sh

RUN chown -R appdynamics:appdynamics /install

# Install AppDynamics Platform and exit - for manual install/upgrade use 'docker run ... controller-install bash'
CMD /install/install-appdynamics.sh
