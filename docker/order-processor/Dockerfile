# Dockerfile for Order Processor
FROM python:3.8
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "processor.py"]
