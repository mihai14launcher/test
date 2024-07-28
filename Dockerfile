# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify \
    wget \
    sudo \
    supervisor && \
    apt-get clean

# Allow root to use VNC without a password
RUN mkdir -p /root/.vnc && \
    echo "#!/bin/sh\nxrdb $HOME/.Xresources\nstartxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    echo 'root:root' | chpasswd

# Set up the VNC server
RUN echo "#!/bin/sh\nvncserver :1 -geometry 1280x800 -depth 24 -rfbport 5901" > /root/start-vnc.sh && \
    chmod +x /root/start-vnc.sh

# Set up websockify
RUN mkdir -p /usr/share/novnc/utils/websockify && \
    echo "#!/bin/sh\nwebsockify --web=/usr/share/novnc/ --wrap-mode=ignore 6901 localhost:5901" > /root/start-websockify.sh && \
    chmod +x /root/start-websockify.sh

# Set up supervisor configuration directly in Dockerfile
RUN mkdir -p /etc/supervisor/conf.d && \
    echo "[supervisord]\nnodaemon=true\n" > /etc/supervisor/supervisord.conf && \
    echo "[program:vncserver]\ncommand=/root/start-vnc.sh\nautostart=true\nautorestart=true\nstdout_logfile=/var/log/supervisor/vncserver.log\nstderr_logfile=/var/log/supervisor/vncserver_error.log\n" >> /etc/supervisor/supervisord.conf && \
    echo "[program:websockify]\ncommand=/root/start-websockify.sh\nautostart=true\nautorestart=true\nstdout_logfile=/var/log/supervisor/websockify.log\nstderr_logfile=/var/log/supervisor/websockify_error.log\n" >> /etc/supervisor/supervisord.conf

# Expose the VNC and websockify ports
EXPOSE 5901 6901

# Start supervisor to manage VNC and websockify
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

