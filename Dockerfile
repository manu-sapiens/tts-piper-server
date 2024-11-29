# Use a slim Python 3.10 base image
FROM python:3.10-slim

# Set working directory inside the container
WORKDIR /piper

# Install dependencies
RUN pip install piper-tts fastapi uvicorn python-multipart

# Copy the voices directory into the container
COPY voices /piper/voices/

# Copy the API script
COPY api.py /piper/

# Create the output directory inside the container
RUN mkdir /piper/output

# Expose the FastAPI port
EXPOSE 8038

# Start the FastAPI server
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "8038"]
