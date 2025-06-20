#!/bin/sh

# Replace the API_URL in the generated JavaScript
if [ -n "$API_URL" ]; then
  echo "Setting API_URL to $API_URL"
  find /usr/share/nginx/html -name "*.js" -exec sed -i "s|http://localhost:8080|$API_URL|g" {} \;
  find /usr/share/nginx/html -name "*.js" -exec sed -i "s|http://10.0.2.2:8080|$API_URL|g" {} \;
fi

# Start nginx
exec nginx -g 'daemon off;'
