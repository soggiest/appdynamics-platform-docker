FROM ubuntu

MAINTAINER Mark Prichard (mark.prichard@appdynamics.com)

# Update the repository sources list
RUN apt-get update && apt-get -y upgrade

# Add the package verification key
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10

# Install Oracle Java 7
RUN apt-get install -y python-software-properties
RUN apt-get install -y software-properties-common
RUN add-apt-repository -y ppa:webupd8team/java
RUN echo 'oracle-java7-installer shared/accepted-oracle-license-v1-1 select true' | sudo /usr/bin/debconf-set-selections
RUN apt-get update && apt-get -y upgrade
RUN apt-get install -y oracle-java7-installer

# Install project dependencies
RUN apt-get install -y ant
RUN apt-get install -y libaio1

# Enable SSH
RUN apt-get install -y openssh-server openssh-client
RUN update-rc.d ssh enable

# Add appdynamics user and set permissions
RUN groupadd -r appdynamics
RUN useradd --create-home --gid appdynamics appdynamics
RUN echo 'appdynamics:appdynamics' | chpasswd
RUN mkdir -p /appdynamics
RUN chown -R appdynamics:appdynamics /appdynamics

# Set ulimit for open files
RUN echo "appdynamics hard nofile 65536" >  /etc/security/limits.d/appdynamics
RUN echo "appdynamics soft nofile 65536" >> /etc/security/limits.d/appdynamics

