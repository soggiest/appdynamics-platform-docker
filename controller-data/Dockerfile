FROM centos:centos6

# Add appdynamics user and set permissions
RUN groupadd -r -g 2002 appdynamics
RUN useradd --create-home --gid appdynamics -u 2001 appdynamics

RUN mkdir -p /appdynamics && chown -R appdynamics:appdynamics /appdynamics
VOLUME /appdynamics

CMD ["echo", "Persistent data container for Appdynamics Controller"]

