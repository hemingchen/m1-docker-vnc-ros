# This Dockerfile builds a headless Ubuntu image with VNC and ROS on Macs with M1 chip
FROM ubuntu:18.04

### Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901
EXPOSE $VNC_PORT $NO_VNC_PORT

### Envrionment config
ENV HOME=/headless \
    TERM=xterm \
    STARTUPDIR=/dockerstartup \
    INST_SCRIPTS=/headless/install \
    NO_VNC_HOME=/usr/share/novnc \
    DEBIAN_FRONTEND=noninteractive \
    VNC_VIEW_ONLY=false
WORKDIR $HOME

RUN apt update

### Install xfce UI
RUN apt install -y supervisor xfce4 xfce4-terminal
RUN apt purge -y pm-utils xscreensaver*

### Install some common tools
RUN apt install -y vim nano wget curl net-tools locales bzip2 git python-numpy
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

### Install xvnc-server & noVNC - HTML5 based VNC viewer
RUN apt install -y tigervnc-standalone-server
RUN apt install -y novnc
# Create index.html to forward automatically to `vnc_lite.html`
RUN ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html

### Install browser
RUN apt install -y chromium-browser chromium-browser-l10n chromium-codecs-ffmpeg
RUN ln -s /usr/bin/chromium-browser /usr/bin/google-chrome
# fix to start chromium in a Docker container, see https://github.com/ConSol/docker-headless-vnc-container/issues/2
RUN echo "CHROMIUM_FLAGS='--no-sandbox --start-maximized --user-data-dir'" > $HOME/.chromium-browser.init

### Install ROS - root is used to run all ROS projects
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -
RUN apt update && apt install -y ros-melodic-desktop
RUN apt install -y python-rosdep python-rosinstall python-rosinstall-generator python-wstool build-essential

# Setup ROS
RUN rosdep init
RUN rosdep fix-permissions
RUN rosdep update

RUN echo "source /opt/ros/melodic/setup.bash" >> ~/.bashrc
RUN /bin/bash -c "source ~/.bashrc"

### Install Gazebo
RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
RUN curl -s https://packages.osrfoundation.org/gazebo.key | apt-key add -
RUN apt update && apt install -y gazebo11 libgazebo11-dev

### Configure startup
ADD ./src/ubuntu/startup $STARTUPDIR
ADD ./src/ubuntu/xfce/ $HOME/
ADD ./src/ubuntu/install $INST_SCRIPTS
RUN find $INST_SCRIPTS -name '*.sh' -exec chmod a+x {} +

RUN apt install -y libnss-wrapper gettext
RUN echo 'source $STARTUPDIR/generate_container_user' >> $HOME/.bashrc
RUN $INST_SCRIPTS/set_user_permission.sh $STARTUPDIR $HOME

### Clean up
RUN apt clean

ENTRYPOINT ["/dockerstartup/vnc_startup.sh"]
CMD ["-w"]