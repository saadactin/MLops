# 1. Base Python image
FROM python:3.11-slim

# 2. Set isolated working directory
WORKDIR /app

# 3. Copy dependencies and install them
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy the Python application code
COPY app.py .

# 5. Expose application port
EXPOSE 5000

# 6. Command to start the application
CMD ["python", "app.py"]

