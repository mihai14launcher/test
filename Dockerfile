# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    openssh-server \
    curl \
    gnupg2 \
    apt-transport-https && \
    apt-get clean

# Install GoTTY
RUN wget -O gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty.tar.gz -C /usr/local/bin && \
    rm gotty.tar.gz

# Allow root to use SSH without a password
RUN echo 'root:root' | chpasswd

# Configure SSH server
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# Set the TERM environment variable
ENV TERM=xterm

# Copy the start script into the image
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose the web terminal port
EXPOSE 8080

# Set the default command to run the start script
CMD ["/start.sh"]
