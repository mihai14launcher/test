# Use the official Kali Linux image as the base image
FROM kalilinux/kali-rolling

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    openssh-server \
    curl \
    gnupg2 \
    apt-transport-https \
    bash \
    && apt-get clean

# Install GoTTY
RUN wget -O gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz && \
    tar -xvf gotty.tar.gz -C /usr/local/bin && \
    rm gotty.tar.gz

# Configure SSH server
RUN mkdir -p /var/run/sshd && \
    echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
    echo 'root:root' | chpasswd

# Set up GoTTY to start on port 8080
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Expose the ports
EXPOSE 22 8080

# Set the default command to run the start script
CMD ["/start.sh"]
