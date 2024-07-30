# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    wget \
    sudo \
    supervisor \
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

# Set up supervisor configuration
RUN mkdir -p /etc/supervisor/conf.d
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisor/supervisord.conf && \
    echo "[program:sshd]\ncommand=/usr/sbin/sshd -D\n" >> /etc/supervisor/supervisord.conf && \
    echo "[program:gotty]\ncommand=/usr/local/bin/gotty -w --port 8080 --permit-write --permit-arguments /bin/bash\n" >> /etc/supervisor/supervisord.conf

# Expose the web terminal port
EXPOSE 8080

# Start supervisor to manage SSH and GoTTY
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
