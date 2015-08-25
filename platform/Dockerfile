FROM appdynamics/base-centos

MAINTAINER mark.prichard@appdynamics.com

# Add AppDynamics Platform start/stop scripts to /usr/bin
ADD /start-appdynamics.sh /usr/bin/start-appdynamics
RUN chmod 744 /usr/bin/start-appdynamics
ADD /stop-appdynamics.sh /usr/bin/stop-appdynamics
RUN chmod 744 /usr/bin/stop-appdynamics

# Set .bash_profile for user 'appdynamics'
ADD /.bash_profile /home/appdynamics/
RUN chown appdynamics:appdynamics /home/appdynamics/.bash_profile
RUN chmod 774 /home/appdynamics/.bash_profile

# Controller 
EXPOSE 8090
# MySQL
EXPOSE 3388
# EUM 
EXPOSE 7001
# Events Service
EXPOSE 9080
EXPOSE 9081
# SSH
EXPOSE 22

# Default to bash - to start use 'docker run ... controller start-appdynamics'
CMD ["/bin/bash"]
