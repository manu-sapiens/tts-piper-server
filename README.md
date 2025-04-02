# TTS Piper Server

A FastAPI server that provides a REST API for text-to-speech synthesis using the Piper TTS engine.

## Features

- Text-to-speech synthesis via REST API
- Support for multiple voices
- Docker containerization for easy deployment
- Docker Hub integration for image distribution

## Prerequisites

- Docker
- Docker Compose (optional, for using docker-compose.yml)

## Quick Start

### Using Docker Hub Image

1. Create a `.env` file with your Docker Hub username:
   ```
   DOCKER_USERNAME=yourusername
   ```

2. Run the container:
   ```
   run.bat
   ```
   
   Or use the direct Docker command:
   ```
   run_direct.bat
   ```

### Building Locally

1. Build the Docker image:
   ```
   build.bat
   ```

2. Run the container:
   ```
   run.bat
   ```

## API Endpoints

- `POST /tts`: Convert text to speech
- `GET /voices`: List available voices
- `GET /health`: Health check endpoint

## Docker Hub Integration

This project includes scripts to help you manage the Docker image on Docker Hub:

1. **build.bat**: Builds the Docker image locally
2. **publish.bat**: Builds and pushes the image to Docker Hub
3. **run.bat**: Runs the container using docker-compose
4. **run_direct.bat**: Runs the container using direct Docker commands

### Publishing to Docker Hub

1. Make sure you have a Docker Hub account
2. Create a `.env` file with your Docker Hub username
3. Run `publish.bat` to build and push the image to Docker Hub

### Running from Docker Hub

Once published, you can run the container directly from Docker Hub:

1. Make sure your `.env` file contains your Docker Hub username
2. Run `run.bat` or `run_direct.bat`

## Configuration

The server can be configured using environment variables:

- `TZ`: Timezone (default: UTC)

## Project Structure

- `api.py`: FastAPI server implementation
- `Dockerfile`: Docker container definition
- `docker-compose.yml`: Docker Compose configuration
- `voices/`: Directory containing voice models
- `.env`: Configuration file for Docker Hub username
- `build.bat`: Script to build the Docker image locally
- `publish.bat`: Script to publish the image to Docker Hub
- `run.bat`: Script to run the container using docker-compose
- `run_direct.bat`: Script to run the container directly

## License

[Include license information here]
