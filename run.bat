@echo off
setlocal enabledelayedexpansion

echo ===== Running Docker Container =====
echo.

REM Get Docker Hub username from .env file
if exist .env (
    for /f "tokens=2 delims==" %%a in ('findstr "DOCKER_USERNAME" .env') do set DOCKER_USERNAME=%%a
    REM Trim any spaces from the username
    set DOCKER_USERNAME=!DOCKER_USERNAME: =!
)

if "!DOCKER_USERNAME!"=="" (
    echo WARNING: Docker Hub username not found in .env file.
    echo Using local build instead of Docker Hub image.
    docker-compose up -d
) else (
    REM Stop and remove any existing containers completely
    echo Stopping and removing existing containers...
    docker-compose down --volumes --remove-orphans

    REM Set the DOCKER_USERNAME environment variable for docker-compose
    set "DOCKER_USERNAME=!DOCKER_USERNAME!"
    
    REM Pull the latest image from Docker Hub
    echo Pulling latest image from Docker Hub...
    echo docker-compose pull
    docker-compose pull

    REM Start the container with a clean slate
    echo Starting container...
    docker-compose up -d
)

echo.
echo Container started successfully.
echo.