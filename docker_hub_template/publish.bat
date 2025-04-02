@echo off
setlocal enabledelayedexpansion

echo ===== Docker Hub Publishing Script =====
echo.

REM Get Docker Hub username from .env file or prompt user
if exist .env (
    for /f "tokens=2 delims==" %%a in ('findstr "DOCKER_USERNAME" .env') do set DOCKER_USERNAME=%%a
)

if "!DOCKER_USERNAME!"=="yourusername" (
    echo Please enter your Docker Hub username:
    set /p DOCKER_USERNAME=
    
    REM Update the .env file with the provided username
    echo # Replace with your Docker Hub username > .env
    echo DOCKER_USERNAME=!DOCKER_USERNAME! >> .env
    
    echo Updated .env file with your username.
    echo.
)

REM Get the current folder name as the project name
for %%I in (.) do set PROJECT_NAME=%%~nxI

echo Building image locally...
docker-compose build

REM Get the service name from docker-compose.yaml
for /f "tokens=1 delims=:" %%s in ('findstr /R "^  [a-zA-Z0-9-]*:" docker-compose.yaml') do (
    set SERVICE_NAME=%%s
    set SERVICE_NAME=!SERVICE_NAME:~2!
    goto :found_service
)
:found_service

echo.
echo Tagging image as !DOCKER_USERNAME!/%PROJECT_NAME%:latest
docker tag %PROJECT_NAME%-%SERVICE_NAME%:latest !DOCKER_USERNAME!/%PROJECT_NAME%:latest

echo.
echo Pushing to Docker Hub...
docker push !DOCKER_USERNAME!/%PROJECT_NAME%:latest

echo.
echo Image successfully pushed to Docker Hub as !DOCKER_USERNAME!/%PROJECT_NAME%:latest
echo You can now run the application using run.bat or run_direct.bat
echo.
pause

endlocal
