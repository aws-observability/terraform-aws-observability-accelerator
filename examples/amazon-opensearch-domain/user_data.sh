#!/bin/bash
yum update -y
yum install jq -y
yum install nginx.x86_64 -y
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt -subj /C=US/ST=./L=./O=./CN=.\n

cat << EOF > /etc/nginx/conf.d/nginx_opensearch.conf
server {
    listen 443 ssl;
    server_name \$host;
    rewrite ^/$ https://\$host/_dashboards redirect;

    # openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/cert.key -out /etc/nginx/cert.crt -subj /C=US/ST=./L=./O=./CN=.\n
    ssl_certificate           /etc/nginx/cert.crt;
    ssl_certificate_key       /etc/nginx/cert.key;

    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;


    location ^~ /_dashboards {
        # Forward requests to OpenSearch Dashboards
        proxy_pass https://DOMAIN_ENDPOINT/_dashboards;

        # Update cookie domain and path
        proxy_cookie_domain DOMAIN_ENDPOINT \$host;

        proxy_set_header Accept-Encoding "";
        sub_filter_types *;
        sub_filter DOMAIN_ENDPOINT \$host;
        sub_filter_once off;

        # Response buffer settings
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
}
EOF
sed -i -e "s/DOMAIN_ENDPOINT/${os_domain}/g" /etc/nginx/conf.d/nginx_opensearch.conf
systemctl restart nginx.service
systemctl enable nginx.service
