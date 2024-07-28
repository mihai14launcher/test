# Use a base image compatible with Raspberry Pi
FROM arm32v7/debian:latest

# Install necessary packages
RUN apt-get update && apt-get install -y \
    xfce4 \
    xfce4-goodies \
    tightvncserver \
    novnc \
    websockify \
    supervisor \
    xterm \
    wget

# Create necessary directories
RUN mkdir -p /root/.vnc /etc/supervisor/conf.d /usr/share/novnc/utils/websockify

# Set up the VNC startup script
RUN echo '#!/bin/sh\n' > /root/.vnc/xstartup && \
    echo 'xrdb $HOME/.Xresources\n' >> /root/.vnc/xstartup && \
    echo 'startxfce4 &' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Set up the VNC server
RUN echo '#!/bin/sh\n' > /root/start-vnc.sh && \
    echo 'vncserver :1 -geometry 1280x800 -depth 24 -rfbport 5901' >> /root/start-vnc.sh && \
    chmod +x /root/start-vnc.sh

# Set up websockify
RUN echo '#!/bin/sh\n' > /root/start-websockify.sh && \
    echo 'websockify --web=/usr/share/novnc/ --wrap-mode=ignore --cert=/root/self.pem 6901 localhost:5901' >> /root/start-websockify.sh && \
    chmod +x /root/start-websockify.sh

# Set up supervisor configuration
RUN echo '[supervisord]\nnodaemon=true\n' > /etc/supervisor/supervisord.conf && \
    echo '[program:vncserver]\ncommand=/root/start-vnc.sh\nautorestart=true\n' >> /etc/supervisor/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/vncserver.log\nstderr_logfile=/var/log/supervisor/vncserver_error.log\n' >> /etc/supervisor/supervisord.conf && \
    echo '[program:websockify]\ncommand=/root/start-websockify.sh\nautorestart=true\n' >> /etc/supervisor/supervisord.conf && \
    echo 'stdout_logfile=/var/log/supervisor/websockify.log\nstderr_logfile=/var/log/supervisor/websockify_error.log\n' >> /etc/supervisor/supervisord.conf

# Expose the VNC and websockify ports
EXPOSE 5901 6901

# Start supervisor to manage VNC and websockify
CMD ["/usr/bin/supervisord"]
