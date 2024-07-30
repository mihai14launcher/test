# A PufferPanel Docker Image that runs inside of a Docker Container
# Using Base image Ubuntu
FROM ubuntu:latest

# Update the system, install necessary packages, and clean up
RUN apt-get update && \
    apt-get install -y \
        python3-pip \
        curl \
        wget \
        zip \
        tar \
        nano \
        htop \
        neofetch && \
    rm -rf /var/lib/apt/lists/*

# Download and install PufferPanel
RUN curl -s https://packagecloud.io/install/repositories/pufferpanel/pufferpanel/script.deb.sh | bash && \
    apt-get update && \
    apt-get install -y pufferpanel && \
    apt-get clean

# Add a PufferPanel user
RUN pufferpanel user add --email puff@docker.local --username Docker --password pufferpanel

# Expose the ports used by PufferPanel
EXPOSE 5657
EXPOSE 8080

# Start PufferPanel service
CMD ["pufferpanel", "serve"]
