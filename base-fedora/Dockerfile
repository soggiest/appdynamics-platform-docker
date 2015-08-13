FROM fedora

MAINTAINER Mark Prichard (mark.prichard@appdynamics.com)

# Install libs
RUN yum makecache fast
RUN yum install -y libaio-devel
RUN yum install -y wget
RUN yum install -y unzip
RUN yum install -y tar

# Enable SSH
RUN yum -y install openssh-server openssh-clients
RUN chkconfig sshd on

# Install Oracle Java 7
RUN wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie " http://download.oracle.com/otn-pub/java/jdk/7u71-b14/jdk-7u71-linux-x64.rpm -O jdk-linux-x64.rpm
RUN rpm -Uvh jdk-linux-x64.rpm
RUN rm jdk-linux-x64.rpm
ENV JAVA_HOME /usr/java/default
ENV PATH $PATH:$JAVA_HOME/bin

# Add appdynamics user and set permissions
RUN groupadd -r appdynamics
RUN useradd --create-home --gid appdynamics appdynamics
RUN echo 'appdynamics:appdynamics' | chpasswd
RUN mkdir -p /appdynamics
RUN chown -R appdynamics:appdynamics /appdynamics

