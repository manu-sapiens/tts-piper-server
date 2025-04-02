@echo off
echo ===== Building Docker Image Locally =====
echo.

REM Build the image locally
docker-compose build

echo.
echo Image successfully built locally.
echo You can now run the application using run.bat or run_direct.bat
echo.
pause
