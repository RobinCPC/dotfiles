#!/bin/bash
# -------------------------------------------------------------------------
# Source: https://gist.github.com/bugra-derre/2fcfb0b77d94031e7446838f4d4f2084
# [Bugra]  install_ros_kinetic_on_ubuntu.sh
#          An installation script to install ROS on top of Ubuntu Xenial.
# -------------------------------------------------------------------------
doTheInstallation() {
    # setup my sources.list
    sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'
    # set up your keys
    sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-key 421C365BD9FF1F717815A3895523BAEEB01FA116
    # installation
    sudo apt-get update
    if ( [ "$OPTARG" == "server" ] || [ "$OPTARG" == "s" ] ); then
        sudo apt-get install ros-kinetic-ros-base
        echo "install server version. no GUI tools" $OPTARG >&2
    elif ( [ "$OPTARG" == "desktop" ] || [ "$OPTARG" == "d" ] ); then
        sudo apt-get install ros-kinetic-desktop-full
        echo "install desktop version. with rviz, rqt" $OPTARG >&2
    else
        echo "Wrong argument. Must be either (s)erver or (d)esktop" >&2
        exit 1
    fi
    # install your individual packages here, e.g.
    # apt-get install ros-kinetic-YOURPACKAGE
    # find available packages with
    # apt-cache search ros-kinetic
    # init rosdep
    sudo rosdep init
    rosdep update
    # environment setup
    echo "source /opt/ros/kinetic/setup.bash" >> ~/.bashrc
    source ~/.bashrc
    # get rosinstall and catkin_tools
    sudo apt-get install python-rosinstall catkin_tools
}

isCorrectUbuntuDistribution() {
    distrib_id= sudo cat /etc/lsb-release | grep DISTRIB_ID | sed 's/.*ID=//'
    distrib_release= sudo cat /etc/lsb-release | grep DISTRIB_RELEASE | sed 's/.*RELEASE=//'
    if ( ! [ "$distrib_id"="Ubuntu" ] && [ "$distrib_release"="16.04" ] )
    then
        echo "Wrong distribution. Must be Ubuntu Xenial 16.04." >&2
        exit 1
    fi
}

isReleaseInformationAvailable() {
    if ( ! [ -e "/etc/lsb-release" ] && [ -f "/etc/lsb-release" ] )
    then
        echo "file /etc/lsb-release does not exist. Wrong distribution. Must be Ubuntu Xenial 16.04." >&2
        exit 1
    fi
}

beginInstallation() {
    isReleaseInformationAvailable
    isCorrectUbuntuDistribution
    doTheInstallation
}

printUsage() {
    echo "Usage: $0 [OPTION]..." >&2
    echo "Install ROS on Ubuntu Xenial 16.04."
    echo -e "\n  -m\t select installation mode, either (s)erver or (d)esktop. This option is mandatory."
    echo -e "  -h\t display help"
    echo -e "\nExamples:"
    echo -e "$0 -m server\tInstall ROS for Ubuntu Server distribution (having no rviz)."
    echo -e "$0 -m desktop\tInstall ROS for Ubuntu Desktop distribution (having rviz)."
}

if [ $# -eq 0 ]
then
    printUsage
    exit 1
fi

while getopts ":hm:" opt; do
  case $opt in
    h) echo ;printUsage;;
    m) echo "begin installation..." >&2;beginInstallation;;
    :) echo "Option -$OPTARG requires an argument" >&2;exit 1;;
    ?) echo "Invalid option: -$OPTARG" >&2;exit 1;;
  esac
done
