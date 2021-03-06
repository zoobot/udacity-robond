FROM yrahal/dev-machine:latest

MAINTAINER Youcef Rahal

USER root

# Rename orion user/group to bender
RUN usermod -l bender -m -d /home/bender orion
RUN groupmod -n bender orion

# The next commands will be run as the new user
USER bender

RUN sudo apt-get update --fix-missing

# Install ROS Kinetic - See http://wiki.ros.org/kinetic/Installation/Ubuntu
RUN sudo add-apt-repository "deb http://archive.ubuntu.com/ubuntu $(lsb_release -sc) universe restricted multiverse"
#sudo apt-get update
RUN sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
RUN sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
RUN sudo apt-get update
RUN sudo apt-get install -y ros-kinetic-desktop-full
RUN sudo rosdep init
RUN rosdep update
RUN echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
#RUN source ~/.bashrc
RUN sudo apt-get install -y python-rosinstall python-rosinstall-generator python-wstool build-essential

# Install catkin_tools - See https://catkin-tools.readthedocs.io/en/latest/installing.html
RUN sudo apt-get install -y python-catkin-tools

# Pip and sympy/sklearn/scipy
RUN sudo apt-get install -y python-pip
RUN pip install sympy sklearn scipy

# This one needs to be installed manually... - See https://github.com/qboticslabs/mastering_ros/issues/7
RUN sudo apt-get install -y ros-kinetic-joint-state-controller

# Gazebo > 7.7.0 - See https://github.com/udacity/RoboND-Kinematics-Project
# RUN sh -c 'echo "deb http://packages.osrfoundation.org/gazebo/ubuntu-stable `lsb_release -cs` main" > /etc/apt/sources.list.d/gazebo-stable.list'
# RUN wget http://packages.osrfoundation.org/gazebo.key -O - | sudo apt-key add -
# RUN apt-get update
# RUN apt-get install -y gazebo7
# RUN rm *.deb

# Install dependencies for P2 and P3
RUN cd && \
    mkdir src && \
    cd src && \
    git clone https://github.com/udacity/RoboND-Kinematics-Project && \
    cd .. && \
    rosdep install --from-paths src --ignore-src --rosdistro=kinetic -y && \
    rm -rf src

RUN cd && \
    mkdir src && \
    cd src && \
    git clone https://github.com/udacity/RoboND-Perception-Project && \
    cd .. && \
    rosdep install --from-paths src --ignore-src --rosdistro=kinetic -y && \
    rm -rf src

# P3 Excerices
RUN cd && \
    pip install cython && \
    git clone https://github.com/udacity/RoboND-Perception-Exercises && \
    cd RoboND-Perception-Exercises/python-pcl && \
    python setup.py build && \
    sudo python setup.py install && \
    sudo apt-get install pcl-tools && \
    cd - && \
    rosdep install --from-paths RoboND-Perception-Exercises/Exercise-2 --ignore-src --rosdistro=kinetic -y && \
    rosdep install --from-paths RoboND-Perception-Exercises/Exercise-3 --ignore-src --rosdistro=kinetic -y && \
    sudo rm -r RoboND-Perception-Exercises

# Clean
RUN sudo apt-get clean && \
    sudo apt-get autoremove && \
    sudo rm -r /var/lib/apt/lists/*

#echo "source ~/catkin_ws/devel/setup.bash"  >> ~/.bashrc

# These should be a config in the launch files?
RUN echo "export GAZEBO_MODEL_PATH=~/catkin_ws/src/RoboND-Kinematics-Project/kuka_arm/models:\$GAZEBO_MODEL_PATH" >> ~/.bashrc
RUN echo "export GAZEBO_MODEL_PATH=~/catkin_ws/src/RoboND-Perception-Project/pr2_robot/models:\$GAZEBO_MODEL_PATH" >> ~/.bashrc
RUN echo "export GAZEBO_MODEL_PATH=~/catkin_ws/src/sensor_stick/models:\$GAZEBO_MODEL_PATH" >> ~/.bashrc
