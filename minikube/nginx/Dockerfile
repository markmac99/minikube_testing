# Official Nginx image
FROM nginx:latest

# Copy Nginx configuration file to the container
COPY nginx.conf /etc/nginx/nginx.conf

# Copy minikube certs and password
COPY minikube/client.key /etc/nginx/certs/minikube-client.key
COPY minikube/client.crt /etc/nginx/certs/minikube-client.crt
COPY minikube/.htpasswd /etc/nginx/.htpasswd

# Expose port 80 and 443
EXPOSE 80
EXPOSE 443
