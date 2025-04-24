# Authenticated Ollama

This project provides an authenticated proxy for the Ollama server using FastAPI and Caddy. It is designed specifically for macOS users who want to self-host an Ollama server and securely connect to it from another machine. Authentication is a crucial feature, ensuring that only authorized users can access the server.

## Project Structure
```
authenticated-ollama/
├── docker/
│   ├── docker-compose.yaml       # Docker Compose configuration
│   ├── authentication-service/   # FastAPI-based authentication service
│   │   ├── app/
│   │   │   ├── main.py           # FastAPI app for API key validation
│   │   │   └── __init__.py
│   │   ├── Dockerfile            # Dockerfile for the authentication service
│   │   ├── requirements.txt      # Python dependencies
│   │   └── valid_keys.conf       # List of valid API keys
│   ├── caddy-server/             # Caddy reverse proxy configuration
│   │   ├── Caddyfile             # Caddy configuration
│   │   └── Dockerfile            # Dockerfile for the Caddy server
├── local-mac/                    # macOS-specific setup
│   ├── Caddyfile                 # Caddy configuration for macOS
│   ├── start_services_mac.sh     # Script to start services on macOS
│   └── valid_keys.conf           # List of valid API keys for macOS
├── .gitignore                    # Git ignore rules
└── README.md                     # Project documentation
```

## Prerequisites
- Docker and Docker Compose installed.
- For macOS: Python 3.9+ and `pip` installed.

## Running with Docker (Recommended)
1. Start the Ollama server:
   ```sh
   ollama serve
   ```
2. Navigate to the `docker` directory:
   ```sh
   cd docker
   ```
3. Start the services:
   ```sh
   docker compose up -d
   ```
4. Test with a valid API key:
   ```sh
   curl https://localhost:8081/api/tags -H "Authorization: Bearer <valid_api_key>"
   ```
5. Test with an invalid API key:
   ```sh
   curl https://localhost:8081/api/tags -H "Authorization: Bearer <invalid_api_key>"
   ```

## Running on macOS
1. Copy the configuration files:
   ```sh
   cp local-mac/valid_keys.conf $HOME/caddy/valid_keys.conf
   cp local-mac/Caddyfile $HOME/caddy/Caddyfile
   ```
2. Add valid API tokens to `$HOME/caddy/valid_keys.conf`.
3. Install dependencies:
   ```sh
   pip install fastapi uvicorn
   ```
4. Make the startup script executable:
   ```sh
   chmod +x local-mac/start_services_mac.sh
   ```
5. Start the services:
   ```sh
   ./local-mac/start_services_mac.sh
   ```

## Configuration
- **API Keys**: Add valid API keys to `valid_keys.conf` in the appropriate directory.
- **Caddy Configuration**: Modify the `Caddyfile` as needed for your environment.

## Logs
- Docker logs can be accessed using:
  ```sh
  docker logs <container_name>
  ```
- On macOS, logs are stored in `$HOME/Library/Logs/service_monitor.log`.

## License
This project is licensed under the MIT License.