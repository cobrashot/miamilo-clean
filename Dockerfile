FROM nginx:alpine

# Copy website files
COPY pages/ /usr/share/nginx/html/pages/
COPY src/ /usr/share/nginx/html/src/
COPY designs/ /usr/share/nginx/html/designs/ 2>/dev/null || true

# Configure nginx
RUN echo 'server {\n\
    listen 80;\n\
    server_name _;\n\
    root /usr/share/nginx/html;\n\
    index pages/index.html;\n\
    location / {\n\
        try_files $uri $uri/ =404;\n\
    }\n\
    location ~ \\.(jpg|jpeg|png|gif|ico|svg|webp)$ {\n\
        expires 7d;\n\
        add_header Cache-Control "public, max-age=604800";\n\
        try_files $uri =404;\n\
    }\n\
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]