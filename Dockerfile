FROM nginx:alpine

# Copy the static HTML file to the Nginx web server directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80 to the outside world
EXPOSE 80


RUN whoami
RUN which mkdir

# Create a directory
RUN mkdir -p /home/appuser


# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]