FROM python:3.13.3-alpine

# Set the working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt requirements.txt

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY /app ./app

COPY valid_keys.conf /etc/caddy/valid_keys.conf

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "9090"]

