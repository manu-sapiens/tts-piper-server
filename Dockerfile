# Use a slim Python 3.10 base image
FROM python:3.10-slim

# Set working directory inside the container
WORKDIR /piper

# Install dependencies
RUN pip install piper-tts fastapi uvicorn python-multipart python-dotenv


# Copy the voices directory into the container
COPY voices /piper/voices/

# Copy the API script
COPY api.py /piper/

# Expose the FastAPI port
EXPOSE 3136

# Start the FastAPI server
CMD ["uvicorn", "api:app", "--host", "0.0.0.0", "--port", "3136"]
