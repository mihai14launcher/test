# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    xfce4 \
    xfce4-goodies \
    xrdp \
    wget \
    sudo \
    supervisor \
    gnupg2 \
    apt-transport-https && \
    apt-get clean

# Install ngrok
RUN wget -qO - https://ngrok-agent.s3.amazonaws.com/ngrok.asc | sudo tee /etc/apt/trusted.gpg.d/ngrok.asc \
    && echo "deb https://ngrok-agent.s3.amazonaws.com buster main" | sudo tee /etc/apt/sources.list.d/ngrok.list \
    && sudo apt update \
    && sudo apt install -y ngrok

# Add ngrok authtoken
ARG 2MExnEkkUINhCYUztZ6pqFtrRJb_2ZE2neXSvVNQqY7AhWjAs
RUN ngrok config add-authtoken ${NGROK_AUTHTOKEN}

# Allow root to use XRDP without a password
RUN mkdir -p /root/.xrdp /etc/supervisor/conf.d && \
    echo 'root:root' | chpasswd && \
    sed -i.bak '/^password\s*required\s*pam_unix.so/ s/^/#/' /etc/pam.d/xrdp-sesman && \
    echo "[XSession]\nname=Xsession\nlib=libxup.so\nusername=ask\npassword=ask" > /etc/xrdp/xrdp.ini && \
    echo "[xrdp1]\nname=Session manager\nlib=libxup.so\nip=127.0.0.1\nport=-1\ntype=vnc-any" >> /etc/xrdp/xrdp.ini

# Set up supervisor configuration
RUN echo "[supervisord]\nnodaemon=true\n" > /etc/supervisor/supervisord.conf && \
    echo "[program:xrdp-sesman]\ncommand=/usr/sbin/xrdp-sesman\n" >> /etc/supervisor/supervisord.conf && \
    echo "[program:xrdp]\ncommand=/usr/sbin/xrdp -nodaemon\n" >> /etc/supervisor/supervisord.conf && \
    echo "[program:ngrok]\ncommand=ngrok tcp 3389\n" >> /etc/supervisor/supervisord.conf

# Expose the RDP port
EXPOSE 3389

# Start supervisor to manage XRDP and ngrok
CMD ["/usr/bin/supervisord"]
