# A pufferpanel Docker Image that runs inside of a Docker Container like a Dind (Docker in Docker)
# Using Base image Ubuntu
FROM ubuntu:latest

# Update the system
RUN apt-get update -y
RUN apt-get upgrade -y

# Create user root
RUN echo 'root:root' | chpasswd

# Install systemctl
RUN apt install systemctl -y

# Install essentials packages

RUN apt install sudo -y
RUN apt install wget -y
RUN apt install curl -y
RUN apt install zip -y
RUN apt install tar -y
RUN apt install untar -y
RUN apt install nano -y
RUN apt install htop -y
RUN apt install neofetch -y


# Starting to download pufferpanel

RUN curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | sudo os=ubuntu dist=jammy bash
RUN sudo apt-get install pufferpanel
RUN sudo systemctl enable --now pufferpanel

# Start the instant script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Starting pufferpanel
CMD ["/start.sh"]
