# Use the official Nginx image as a base
FROM nginx:alpine

# Copy the custom nginx.conf to the container
COPY conf/nginx.conf /etc/nginx/nginx.conf

# Copy the index.html file to the appropriate directory
COPY conf/index.html /usr/share/nginx/html/index.html

CMD [ "chmod 777 /usr/share/nginx/html/index.html" ]

# Expose port 8080
EXPOSE 443