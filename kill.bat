@echo off
set PORT=8038

echo Checking for processes using port %PORT%...
for /f "tokens=5" %%P in ('netstat -ano ^| findstr :%PORT%') do (
    echo Found process ID %%P. Verifying it is not Docker...
    tasklist | findstr /i "docker"
    if errorlevel 1 (
        echo Terminating process ID %%P using port %PORT%...
        taskkill /PID %%P /F
    ) else (
        echo Skipping Docker-related process %%P.
    )
)
echo Done.
