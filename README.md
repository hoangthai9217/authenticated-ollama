# Running with docker (Recommended)
1. Run ollama server
2. cd docker; docker compose up -d
3. curl https://localhost:8081/api/tags -H "Authorization: Bearer ollama-8fc5df19c222d97699f5af5af7881d86"
4. curl https://localhost:8081/api/tags -H "Authorization: Bearer any_invalid_api_key"

# For Mac users, run this directly
1. cp valid_keys.conf $HOME/caddy/valid_keys.conf
2. Put valid api token to HOME/caddy/valid_keys.conf (used in python app)
3. cp Caddyfile $HOME/caddy/Caddyfile
4. pip install fastapi uvicorn
5. chomod +x start_services_mac.sh
6. ./start_services_mac.sh
