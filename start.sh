#!/bin/bash

# Start the SSH server
/usr/sbin/sshd -D &

# Start GoTTY
/usr/local/bin/gotty -w -c 'root:root' --port 8080 /bin/bash
