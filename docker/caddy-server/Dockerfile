FROM caddy:2.10.0-alpine

# Set the working directory
WORKDIR /app

# Copy the Caddyfile
COPY Caddyfile /etc/caddy/Caddyfile

CMD [ "caddy" , "run", "--config", "/etc/caddy/Caddyfile" ]

# Expose the port the app runs on
EXPOSE 8081