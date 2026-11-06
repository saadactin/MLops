FROM python:3.11-slim

WORKDIR /app

# Install the missing dependency
RUN pip install --no-cache-dir requests

COPY app.py /app/app.py

ENV APP_SECRET_KEY=shshsh

EXPOSE 5000

CMD ["python", "app.py"]