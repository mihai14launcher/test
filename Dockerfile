# Use the official PufferPanel image from Docker Hub
FROM pufferpanel/pufferpanel:latest

# Set environment variables for PufferPanel
ENV DB_HOST=db
ENV DB_PORT=3306
ENV DB_NAME=pufferpanel
ENV DB_USER=pufferpanel
ENV DB_PASS=password
ENV PANEL_ADMIN_EMAIL=admin@example.com
ENV PANEL_ADMIN_PASSWORD=admin

# Expose the port that PufferPanel runs on
EXPOSE 8080

# Run PufferPanel
CMD ["pufferpanel", "run"]
