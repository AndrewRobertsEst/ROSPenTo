FROM ros:kinetic-ros-base-xenial

MAINTAINER Víctor Mayoral Vilches<victor@aliasrobotics.com>

RUN apt-get update && apt-get install -y \
    ros-kinetic-robot=1.3.2-0* \
    && rm -rf /var/lib/apt/lists/*

# Install mono
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
RUN apt-get update && apt-get install apt-transport-https
RUN echo "deb https://download.mono-project.com/repo/ubuntu stable-xenial main" | tee /etc/apt/sources.list.d/mono-official-stable.list
RUN apt-get update && apt-get -y install mono-devel
# RUN certmgr -ssl -m https://go.microsoft.com
# RUN certmgr -ssl -m https://nugetgallery.blob.core.windows.net
# RUN certmgr -ssl -m https://nuget.org
# RUN mozroots --import --sync

# Install a few additional dependencies
RUN apt-get install -y nuget

# Install ROSPenTo
COPY . /root/ROSPenTo
RUN cd /root/ROSPenTo && nuget restore && msbuild

#Copy SSH banner
RUN rm -rf /etc/update-motd.d/* && rm -rf /etc/legal && \
  sed -i 's/\#force_color_prompt=yes/force_color_prompt=yes/' /root/.bashrc
COPY motd /etc/motd
RUN echo "cat /etc/motd" >> /root/.bashrc
# Create an alias for ROSPenTo and rospento
RUN echo 'alias ROSPenTo="mono /root/ROSPenTo/RosPenToConsole/bin/Debug/RosPenToConsole.exe"' >> /root/.bashrc
RUN echo 'alias rospento="mono /root/ROSPenTo/RosPenToConsole/bin/Debug/RosPenToConsole.exe"' >> /root/.bashrc

COPY launch_script.bash /root/
ENTRYPOINT ["/root/launch_script.bash"]
