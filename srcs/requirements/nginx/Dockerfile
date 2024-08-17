# Image required by the subject
FROM debian:bullseye

# Update and install nginx
RUN apt update && apt install nginx -y

# Install OpenSSL for certificate
RUN apt install openssl -y

COPY nginx.conf /etc/nginx/

EXPOSE 443