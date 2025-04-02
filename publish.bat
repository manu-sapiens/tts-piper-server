@echo off
setlocal enabledelayedexpansion

echo ===== Docker Hub Publishing Script =====
echo.

REM Get Docker Hub username from .env file or prompt user
if exist .env (
    for /f "tokens=2 delims==" %%a in ('findstr "DOCKER_USERNAME" .env') do set DOCKER_USERNAME=%%a
    REM Trim any spaces from the username
    set DOCKER_USERNAME=!DOCKER_USERNAME: =!
)

if "!DOCKER_USERNAME!"=="" (
    echo Please enter your Docker Hub username:
    set /p DOCKER_USERNAME=
    REM Trim any spaces from the username
    set DOCKER_USERNAME=!DOCKER_USERNAME: =!
    
    REM Update the .env file with the provided username
    echo # Replace with your Docker Hub username > .env
    echo DOCKER_USERNAME=!DOCKER_USERNAME! >> .env
    
    echo Updated .env file with your username.
    echo.
)

echo Building image locally...
docker build -t piper-api .

echo.
set FULL_IMAGE_NAME=!DOCKER_USERNAME!/tts-piper-server:latest
echo Tagging image as !FULL_IMAGE_NAME!
docker tag piper-api !FULL_IMAGE_NAME!

echo.
echo Pushing to Docker Hub...
echo docker push !FULL_IMAGE_NAME!
docker push !FULL_IMAGE_NAME!

echo.
echo Image successfully pushed to Docker Hub as !FULL_IMAGE_NAME!
echo You can now run the application using run.bat or run_direct.bat
echo.
pause

endlocal
