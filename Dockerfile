# A pufferpanel Docker Image that runs inside of a Docker Container like a Dind (Docker in Docker)
# Using Base image Ubuntu
FROM ubuntu:latest

# Update the system and install some packages
RUN apt-get update && \
    apt-get install -y python3-pip && \
    echo 'root:root' | chpasswd && \
    printf '#!/bin/sh\nexit 0' > /usr/sbin/policy-rc.d && \
    apt-get install -y systemd systemd-sysv dbus dbus-user-session && \
    printf "systemctl start systemd-logind" >> /etc/profile

# Install systemctl
RUN apt install systemctl -y

# Install essentials packages

RUN apt install sudo -y
RUN apt install wget -y
RUN apt install curl -y
RUN apt install zip -y
RUN apt install tar -y
RUN apt install nano -y
RUN apt install htop -y
RUN apt install neofetch -y


# Starting to download pufferpanel

RUN curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo os=ubuntu dist=jammy bash
RUN sudo apt-get install pufferpanel
RUN sudo pufferpanel user add --email puff@docker.local --name Docker --password pufferpanel
RUN sudo systemctl enable --now pufferpanel

# Start the instant script
COPY start.sh /start.sh
RUN chmod +x /start.sh

EXPOSE 5657
EXPOSE 8080

# Starting pufferpanel
CMD ["bash"]
