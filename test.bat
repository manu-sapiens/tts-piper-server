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

REM Set output file paths
set OUTPUT_RAW=output\speech.raw
set OUTPUT_WAV=output\speech.wav

REM Make the API call
curl -X POST "%API_URL%" -F "text=%TEXT%" -F "model=%MODEL%" --output %OUTPUT_RAW%

REM Check if the raw audio file was generated
if exist %OUTPUT_RAW% (
    echo Speech synthesis completed. Output saved to %OUTPUT_RAW%.

    REM Convert raw audio to WAV using ffmpeg
    ffmpeg -f s16le -ar 22050 -ac 1 -i %OUTPUT_RAW% %OUTPUT_WAV%

    REM Check if the WAV file was generated
    if exist %OUTPUT_WAV% (
        echo Conversion to WAV completed. Output saved to %OUTPUT_WAV%.

        REM Play the WAV file using ffplay
        ffplay -autoexit -nodisp %OUTPUT_WAV%
    ) else (
        echo ERROR: Failed to convert raw audio to WAV.
    )
) else (
    echo ERROR: Failed to generate speech output.
)
