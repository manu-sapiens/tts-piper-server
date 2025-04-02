@echo off
setlocal enabledelayedexpansion

echo ===== Running Docker Container Directly =====
echo.

REM Get Docker Hub username from .env file
if exist .env (
    for /f "tokens=2 delims==" %%a in ('findstr "DOCKER_USERNAME" .env') do set DOCKER_USERNAME=%%a
    REM Trim any spaces from the username
    set DOCKER_USERNAME=!DOCKER_USERNAME: =!
)

if "!DOCKER_USERNAME!"=="" (
    echo WARNING: Docker Hub username not found in .env file.
    echo Using local image instead of Docker Hub image.
    
    REM Stop and remove any existing container with the same name
    echo Stopping and removing existing container if it exists...
    docker stop piper-tts-container 2>nul
    docker rm piper-tts-container 2>nul
    
    echo Starting container from local image...
    docker run -d --name piper-tts-container ^
      -p 3136:3136 ^
      -v "%CD%/voices:/piper/voices" ^
      -v "%CD%/api.py:/piper/api.py" ^
      -e TZ=UTC ^
      --restart unless-stopped ^
      piper-api
) else (
    REM Stop and remove any existing container with the same name
    echo Stopping and removing existing container if it exists...
    docker stop piper-tts-container 2>nul
    docker rm piper-tts-container 2>nul
    
    REM Pull the latest image from Docker Hub
    echo Pulling latest image from Docker Hub...
    set FULL_IMAGE_NAME=!DOCKER_USERNAME!/tts-piper-server:latest
    echo Pulling !FULL_IMAGE_NAME!
    docker pull !FULL_IMAGE_NAME!
    
    REM Run the container with the same settings as in docker-compose
    echo Starting container...
    docker run -d --name piper-tts-container ^
      -p 3136:3136 ^
      -v "%CD%/voices:/piper/voices" ^
      -v "%CD%/api.py:/piper/api.py" ^
      -e TZ=UTC ^
      --restart unless-stopped ^
      !FULL_IMAGE_NAME!
)

echo.
if %ERRORLEVEL% EQU 0 (
  echo Container started successfully.
  echo Container name: piper-tts-container
  echo Port: 3136
) else (
  echo Failed to start container. Please check the error message above.
)
echo.

endlocal
