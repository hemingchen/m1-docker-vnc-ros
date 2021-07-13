# Docker image with Ubuntu 18.04, ROS, Gazebo, Xfce4, VNC on Apple M1 Silicon

This image is developed based on `ConSol/docker-headless-vnc-container` and `henry2423/ros-vnc-ubuntu:melodic`.

It contains ROS Melodic, Gazebo 11, xfce, vnc, and no-vnc (for vnc through web browser).

It has been tested on Mac with Apple M1 Silicon running macOS 11 Big Sur.

## Usage

### Use supplied script:

- Define environment variables in `env_setup.sh`, then build and run:
  ```
  ./build.sh && ./launch.sh
  ```

### Use docker commands:

- Build:
  ```
  docker build --tag ${IMG_NAME} .
  ```

- Run:
  ```
  docker run \
      --name ${CONTAINER_NAME} \
      -d -p 5901:5901 -p 6901:6901 \
      ${IMG_NAME}
      -w \
      -r "${VNC_RESOLUTION}" \
      -d "${VNC_COL_DEPTH}" \
      -p "${VNC_PW}"
  ```
  
- Options:
  ```
  -w  Mandatory, keeps the UI and the vncserver up until SIGINT or SIGTERM is received
  -r  VNC resolution, default: 1280x720
  -d  VNC color depth, default: 24
  -p  VNC password, default: vncpassword
  ```

## Connect to VNC

Run the container and connect to desktop with:

* __VNC viewer `localhost:5901`__, default password: `vncpassword`
* __noVNC HTML5 full client__: [`http://localhost:6901/vnc.html`](http://localhost:6901/vnc.html), default
  password: `vncpassword`
* __noVNC HTML5 lite
  client__: [`http://localhost:6901/?password=vncpassword`](http://localhost:6901/?password=vncpassword)

## References

* [ConSol/docker-headless-vnc-container](https://github.com/ConSol/docker-headless-vnc-container)

* [henry2423/ros-vnc-ubuntu](https://github.com/henry2423/docker-ros-vnc)

