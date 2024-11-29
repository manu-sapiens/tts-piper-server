@echo off
REM Ensure the output directory exists
if not exist output (
    mkdir output
)

REM Set variables for the API endpoint, model, and input text
set API_URL=http://localhost:8038/synthesize/
set MODEL=en_US-ryan-high

REM Check if text argument is provided
if "%~1"=="" (
    set TEXT=Hello, this is a test of the Piper API!
) else (
    set TEXT=%~1
)

REM Set output file path
set OUTPUT_FILE=output\speech.wav

REM Make the API call
curl -X POST "%API_URL%" -F "text=%TEXT%" -F "model=%MODEL%" --output %OUTPUT_FILE%

REM Check if the audio file was generated
if exist %OUTPUT_FILE% (
    echo Speech synthesis completed. Output saved to %OUTPUT_FILE%.

    REM Play the audio file using the default media player
    start "" "%OUTPUT_FILE%"
) else (
    echo ERROR: Failed to generate speech output.
)
