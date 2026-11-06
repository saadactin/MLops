# 1. Base Image: Lightweight Python 3.11 Linux container
FROM python:3.11-slim

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy our application file from Windows into the container
COPY server.py /app/server.py

# 4. Document the network port
EXPOSE 8080

# 5. The startup command when the container launches
CMD ["python", "server.py"]
