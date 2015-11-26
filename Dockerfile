FROM openshift/tomcat7-openshift

USER 0

RUN mkdir -p /install

RUN yum install -y libaio-devel
RUN yum install -y wget
RUN yum install -y unzip
RUN yum install -y tar

# Enable SSH
RUN yum install -y openssh-server openssh-clients
RUN chkconfig sshd on

# Install Oracle Java 7
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie	" http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm -O jdk-linux-x64.rpm
RUN rpm -Uvh jdk-linux-x64.rpm
RUN rm jdk-linux-x64.rpm
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Add appdynamics user and set permissions
RUN groupadd -r -g 2002 appdynamics
RUN useradd --create-home --gid appdynamics -u 2001 appdynamics
RUN echo 'appdynamics:appdynamics' | chpasswd

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
