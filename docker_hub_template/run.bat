@echo off
echo ===== Running Docker Container =====
echo.

REM Stop and remove any existing containers completely
echo Stopping and removing all containers...
docker-compose down --volumes --remove-orphans

REM Pull the latest image from Docker Hub
echo Pulling latest image from Docker Hub...
docker-compose pull

REM Start the container with a clean slate
echo Starting container...
docker-compose up -d

echo.
echo Container started successfully.
echo.
