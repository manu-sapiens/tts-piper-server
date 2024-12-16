@echo off
REM Test the /voices/ route of the Piper TTS API

REM Set the API endpoint URL
set API_URL=http://localhost:3136/voices/

REM Make the GET request and display the response
curl -s -X GET "%API_URL%"

REM Optional: Save the response to a file
REM Uncomment the following lines if you want to save the output
REM set OUTPUT_FILE=output\voices.json
REM if not exist output (
REM     mkdir output
REM )
REM curl -s -X GET "%API_URL%" --output %OUTPUT_FILE%
REM echo Response saved to %OUTPUT_FILE%
