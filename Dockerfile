# Use the official Alpine Linux image as the base image compatible with ARM architecture
FROM arm32v7/alpine:latest

# Install necessary packages
RUN apk update && \
    apk add --no-cache \
    xfce4 \
    xfce4-terminal \
    tigervnc \
    novnc \
    websockify \
    sudo \
    supervisor \
    bash

# Create necessary directories
RUN mkdir -p /root/.vnc /etc/supervisor/conf.d /usr/share/novnc/utils/websockify

# Allow root to use VNC without a password
RUN echo -e "#!/bin/sh\nxrdb $HOME/.Xresources\nstartxfce4 &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup && \
    echo 'root:root' | chpasswd

# Set up the VNC server
RUN echo -e "#!/bin/sh\nvncserver :1 -geometry 1280x800 -depth 24 -rfbport 5901 -SecurityTypes None" > /root/start-vnc.sh && \
    chmod +x /root/start-vnc.sh

# Set up websockify
RUN echo -e "#!/bin/sh\nwebsockify --web=/usr/share/novnc/ --wrap-mode=ignore 6901 localhost:5901" > /root/start-websockify.sh && \
    chmod +x /root/start-websockify.sh

# Set up supervisor configuration
RUN mkdir -p /etc/supervisord.d && \
    echo -e "[supervisord]\nnodaemon=true\n" > /etc/supervisord.conf && \
    echo -e "[program:vncserver]\ncommand=/root/start-vnc.sh\nautorestart=true\nstdout_logfile=/var/log/supervisor/vncserver.log\nstderr_logfile=/var/log/supervisor/vncserver_error.log\n" >> /etc/supervisord.conf && \
    echo -e "[program:websockify]\ncommand=/root/start-websockify.sh\nautorestart=true\nstdout_logfile=/var/log/supervisor/websockify.log\nstderr_logfile=/var/log/supervisor/websockify_error.log\n" >> /etc/supervisord.conf

# Expose the VNC and websockify ports
EXPOSE 5901 6901

# Start supervisor to manage VNC and websockify
CMD ["/usr/bin/supervisord"]
