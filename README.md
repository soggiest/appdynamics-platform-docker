# AppDynamics Platform Docker Containers
Docker containers for installing and running the AppDynamics Controller with EUM Server and Analytics support on Centos, Fedora or Ubuntu base images. These containers allow you to manage an AppDynamics Platform install using Docker, with persistent data storage for the AppDynamics installation and database.

## Please Note
This project uses a single-host installation for the AppDynamics Controller and End User Monitoring, with the embedded Events Service.  This is suitable for small, demonstration installations only: for production deployments please see the [product documentation](https://docs.appdynamics.com/display/PRO41/Install+the+Events+Service).

## Quick Summary
1. (Initialize data volume) `docker run --name platform-data appdynamics/platform-data`
2. (Install AppDynamics) `docker run --rm -it --name platform-install -h controller --volumes-from platform-data  appdynamics/platform-install`
3. (Add license file) `docker run --rm -it --volumes-from platform-data -v $(pwd)/:/license appdynamics/platform-install bash -c "cp /license/license.lic /appdynamics/Controller"`
4. (Start AppDynamics) `docker run -d --name platform -h controller -p 8090:8090 -p 7001:7001 -p 9080:9080 --volumes-from platform-data appdynamics/platform start-appdynamics`
5. (Stop AppDynamics) `docker exec platform stop-appdynamics`
6. (Restart AppDynamics) `docker exec platform start-appdynamics`

## Base Images
These contain the base OS and any required packages.  To change the OS version or add a package, rebuild the base image, tag it appropriately and update the FROM directive in the platfomr-install and platform Dockerfiles.  To build: e.g. `cd base-centos; docker build -t appdynamics/base-centos .`

1. base-centos (currently uses Centos 6)
2. base-fedora (currently uses Fedora 21) - EXPERIMENTAL, not fully tested
3. base-ubuntu (currently uses Ubuntu Trusty) - EXPERIMENTAL, not fully tested

## Initialize the Data Volume
Creates a data volume with an empty /appdynamics directory, owned by user appdynamics:appdynamics.  This should be run to initialize the data volume before running platform-install to install the AppDynamics Platform. In the following example, the container is called platform-data and this is used with the docker `--volumes-from` flag to identify the data volume when running the platform-install and platform containers. The container exports the data volume, prints a confirmation message and exits. Note that deleting the container will delete the data volume. 

- `docker run --name platform-data platform-data`

## Install the AppDynamics Platform
This contains the scripts and binaries required to install the AppDynamics Platform (Controller, EUEM and Analytics) on a mounted docker volume.  This volume should be initialized first using the platform-data container, before platform-install is run to complete installation.  Normally, you would run `platform-install` once to lay down the /appdynamics install directory, and then use `platform` to start and stop the AppDynamics Controller and EUM Server/Events Service. This container can also be used to upgrade an existing installation or perform a manual install by running it with `bash` as the container entrypoint.

- (normal install) `docker run --rm -it --name platform -h controller --volumes-from platform-data  appdynamics/platform-install`
- (manual install/upgrade) `docker run --rm -it --name platform -h controller --volumes-from platform-data  appdynamics/platform-install bash` 

## Add the License File
You can add the license file either at build time or run time.
#### Run time
Once the platform-install container has started, use `docker run -v` to add your AppDynamics license file. The following command can be used to inject the license file - this needs to run in a separate terminal, while the AppDynamics Controller installation is running:
- `docker run --rm -it --volumes-from platform-data -v $(pwd)/:/license appdynamics/platform-install bash -c "cp /license/license.lic /appdynamics/Controller"`

#### Build time
To add the license file at build time, uncomment the following line in the `platform-install` Dockerfile:
- `ADD /license.lic /install/`

The `build.sh` script will copy the license file (if one exists) from the project root to the `platform-install` directory. As part of the install, the license file will be copied to the `/appdynamics/Controller/` folder. 

## Run the AppDynamics Controller and EUM Server

This contains scripts to run the AppDynamics Platform. It should be used with a mounted docker volume (see `platfrom-data`) containing the /appdynamics install directory created with `platform-install`.  Note that the hostname (set with the -h flag) should match that used for the platform installation.
- `docker run -d --name platform -h controller -p 8090:8090 -p 7001:7001 -p 9080:9080 --volumes-from platform-data appdynamics/platform start-appdynamics`
- `docker exec platform stop-appdynamics`
- `docker exec platfrom start-appdynamics`

## Building the containers
The base images can be build manually from their respective directories.  The `platform`, `platfrom-data` and `platfrom-install` containers should be built using the `build.sh` script. The build requires the following AppDynamics install files, which can be supplied from the commandline or downloaded from the [AppDynamics Download Site](https://download.appdynamics.com/).

1. AppDynamics Ccontroller installer (64-bit Linux) 
2. AppDynamics EUM Server installer (64-bit Linux)

To build the containers, run `build.sh` with one of the following options:

1. Run `build.sh` without commandline args to be prompted (with autocomplete) for the controller and EUM installer paths
2. Run `build.sh -c <path_to_controller_installer> -e <path_to_euem_installer>` to supply installer paths
3. Run `build.sh --download` to download from `https://download.appdynamics.com` (portal login required)

## Connecting to the Controller
You can change any of the ports used in the silent installer response varfiles:
- [controller.varfile](https://github.com/Appdynamics/appdynamics-platform-docker/blob/master/controller.varfile)
- [eum.varfile](https://github.com/Appdynamics/appdynamics-platform-docker/blob/master/eum.varfile)

Note: you will need to rebuild the container images for these changes to take effect.  See the [product documentation](https://docs.appdynamics.com/display/PRO41/Install+the+Controller#InstalltheController-installeroptionsInstallationConfigurationSettings) for more information about the silent installer settings.

You can remap any ports used by the AppDynamics Platform to different ports on your lcoal system, using the `docker run -p` option.  For example `-p 80:8090` will map the Controller server port 8090 to your default HTTP port 80.

If you are using [boot2docker](http://boot2docker.io/) or [docker-machine](https://docs.docker.com/machine/) to run docker on OSX/Windows, you should use the following commands to determine the Docker host's IP address:

- boot2docker: `boot2docker ip`
- docker-machine: `docker-machine ip default`

You can use the following VirtualBox command to map port 8090 on the docker container to your localhost interface 

`VBoxManage controlvm boot2docker-vm natpf1 "8090-8090,tcp,127.0.0.1,8090,,8090"`

## Default logins 

- Controller login: user1/welcome
- Root user login: welcome
