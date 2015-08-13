# AppDynamics Platform Docker Containers
Docker containers for installing and running the AppDynamics Controller with EUM Server and Analytics support on Centos, Fedora or Ubuntu base images. These containers allow you to manage an AppDynamics Platform install using Docker, with persistent data storage for the AppDynamics installation and database.

## Quick Summary
1. (Initialize data volume) `docker run --name controller-data appdynamics/controller-data`
2. (Install AppDynamics) `docker run --rm -it --name controller-install -h controller --volumes-from controller-data  appdynamics/controller-install`
3. (Add license file) `docker run --rm -it --volumes-from controller-data -v $(pwd)/:/license appdynamics/controller-install bash -c "cp /license/license.lic /appdynamics/Controller"`
4. (Start AppDynamics) `docker run -d --name controller -h controller -p 8090:8090 -p 7001:7001 --volumes-from controller-data appdynamics/controller start-appdynamics`
5. (Stop AppDynamics) `docker exec controller stop-appdynamics`
6. (Restart AppDynamics) `docker exec controller start-appdynamics`

## Base Images
These contain the base OS and any required packages.  To change the OS version or add a package, rebuild the base image, tag it appropriately and update the FROM directive in the controller-install and controller Dockerfiles.  To build: e.g. `cd base-centos; docker build -t appdynamics/base-centos .`

1. base-centos (currently uses Centos 6)
2. base-fedora (currently uses Fedora 21) - EXPERIMENTAL, not fully tested
3. base-ubuntu (currently uses Ubuntu Trusty) - EXPERIMENTAL, not fully tested

## Initialize the Data Volume (*controller-data*)
Creates a data volume with an empty /appdynamics directory, owned by user appdynamics:appdynamics.  This should be run to initialize the data volume before running controller-install to install the AppDynamics Platform. In the following example, the container is called controller-data and this is used with the docker `--volumes-from` flag to identify the data volume when running the controller-install and controller containers. The container exports the data volume, prints a confirmation message and exits. Note that deleting the container will delete the data volume. 

- `docker run --name controller-data controller-data`

## Install the AppDynamics Platform (*controller-install*)
This contains the scripts and binaries required to install the AppDynamics Platform (Controller, EUEM and Analytics) on a mounted docker volume.  This volume should be initialized first using the controller-data container, before controller-install is run to complete installation.  Normally, you would run `controller-install` once to lay down the /appdynamics install directory, and then use `controller` to start and stop the AppDynamics Controller and EUM Server/Events Service. This container can also be used to upgrade an existing installation or perform a manual install by running it with `bash` as the container entrypoint.

- (normal install) `docker run --rm -it --name controller -h controller -p 8090:8090 -p 7001:7001 --volumes-from controller-data  appdynamics/controller-install`
- (manual install/upgrade) `docker run --rm -it --name controller -h controller -p 8090:8090 -p 7001:7001 --volumes-from controller-data  appdynamics/controller-install bash` 

## Add the License File
You can add the license file either at build time or run time.
#### Run time
Once the controller container has started, use `docker exec` to add your AppDynamics license file. The following command can be used to inject the license file - this needs to run in a separate terminal, while the AppDynamics Controller installation is running:
- `docker run --rm -it --volumes-from controller-data -v $(pwd)/:/license appdynamics/controller-install bash -c "cp /license/license.lic /appdynamics/Controller"`

#### Build time
To add the license file at build time, uncomment the following line in the `controller-install` Dockerfile:
- `ADD /license.lic /install/`

The `build.sh` script will copy the license file (if one exists) from the project root to the `controller-install` directory. As part of the install, the license file will be copied to the `/appdynamics/Controller/` folder. 

## Run the AppDynamics Controller and Processors (*controller*)

This contains scripts to run the AppDynamics Platform. It should be used with a mounted docker volume (see `controller-data`) containing the /appdynamics install directory created with `controller-install`. In the following example, the mounted volume is called 'controller-data' and the contianer is 'controller'.  Note that the hostname (set with the -h flag) should match that used for the controller installation.
- `docker run -d --name controller -h controller -p 8090:8090 -p 7001:7001 --volumes-from controller-data appdynamics/controller start-appdynamics`
- `docker exec controller stop-appdynamics`
- `docker exec controller start-appdynamics`

## Building the containers
The base images can be build manually from their respective directories.  The `controller`, `controller-data` and `controller-install` containers should be built using the `build.sh` script. The build requires the following AppDynamics install files, which can be supplied from the commandline or downloaded from the [AppDynamics Download Site](https://download.appdynamics.com/).

1. AppDynamics Ccontroller installer (64-bit Linux) 
2. AppDynamics EUM Server installer (64-bit Linux)

To build the containers, run `build.sh` with one of the following options:

1. Run `build-controller.sh` without commandline args to be prompted (with autocomplete) for the controller and EUM installer paths
2. Run `build-controller.sh -c <path_to_controller_installer> -e <path_to_euem_installer>` to supply installer paths
3. Run `build-controller.sh --download` to download from `https://download.appdynamics.com` (portal login required)

## Connecting to the Controller
If you are using [boot2docker](http://boot2docker.io/) to run docker on OSX/Windows, you can use the following VirtualBox command to map port 8090 on the docker container to your localhost interface 

`VBoxManage controlvm boot2docker-vm natpf1 "8090-8090,tcp,127.0.0.1,8090,,8090"`

For the Controller UI, browse to: `http://localhost:8090/controller`

Default controller login: user1/welcome