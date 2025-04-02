@echo off
setlocal enabledelayedexpansion

echo ===== Running Docker Container Directly =====
echo.

REM Get Docker Hub username from .env file
if exist .env (
    for /f "tokens=2 delims==" %%a in ('findstr "DOCKER_USERNAME" .env') do set DOCKER_USERNAME=%%a
)

REM Get the current folder name as the project name
for %%I in (.) do set PROJECT_NAME=%%~nxI

REM Get the service name and port from docker-compose.yaml
for /f "tokens=1 delims=:" %%s in ('findstr /R "^  [a-zA-Z0-9-]*:" docker-compose.yaml') do (
    set SERVICE_NAME=%%s
    set SERVICE_NAME=!SERVICE_NAME:~2!
    goto :found_service
)
:found_service

REM Find the port mapping
for /f "tokens=2 delims=:" %%p in ('findstr /R "^      - \"[0-9]*:" docker-compose.yaml') do (
    set PORT=%%p
    set PORT=!PORT:~1!
    for /f "delims=\" %%n in ("!PORT!") do set PORT=%%n
    goto :found_port
)
:found_port

REM Stop and remove any existing container with the same name
echo Stopping and removing existing container if it exists...
docker stop !PROJECT_NAME!-container 2>nul
docker rm !PROJECT_NAME!-container 2>nul

REM Pull the latest image from Docker Hub
echo Pulling latest image from Docker Hub...
docker pull !DOCKER_USERNAME!/!PROJECT_NAME!:latest

REM Run the container with the same settings as in docker-compose
echo Starting container...
docker run -d --name !PROJECT_NAME!-container ^
  -p !PORT!:!PORT! ^
  -v "%CD%:/app" ^
  -v /app/node_modules ^
  -v "%CD%/data:/app/data" ^
  --restart unless-stopped ^
  !DOCKER_USERNAME!/!PROJECT_NAME!:latest

echo.
if %ERRORLEVEL% EQU 0 (
  echo Container started successfully.
  echo Container name: !PROJECT_NAME!-container
  echo Port: !PORT!
) else (
  echo Failed to start container. Please check the error message above.
)
echo.

endlocal
