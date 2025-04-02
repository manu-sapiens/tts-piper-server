# Docker Hub Template

This template provides a set of scripts to help you manage Docker images across multiple projects using Docker Hub.

## Files Included

1. `.env` - Stores your Docker Hub username
2. `.gitignore` - Excludes sensitive files from git
3. `build.bat` - Builds your Docker image locally
4. `publish.bat` - Builds and pushes your image to Docker Hub
5. `run.bat` - Runs your container using docker-compose
6. `run_direct.bat` - Runs your container using direct Docker commands (more reliable)
7. `docker-compose.yaml` - Example configuration using Docker Hub image

## How to Use

1. Copy these files to your project
2. Edit the `.env` file with your Docker Hub username
3. Modify `docker-compose.yaml` to match your project's needs
4. Update the image name in the scripts if needed

## Workflow

1. Use `build.bat` for local development and testing
2. Use `publish.bat` to save your image to Docker Hub
3. Use `run.bat` or `run_direct.bat` to run your container

This setup ensures your Docker images are safely stored on Docker Hub and won't be lost when your local Docker installation purges images.
