from fastapi import FastAPI, HTTPException, Form
from fastapi.responses import FileResponse
from starlette.background import BackgroundTask
import subprocess
import os
import uuid

app = FastAPI()

# Directories for voices and output
VOICE_DIR = "/piper/voices"
OUTPUT_DIR = "/piper/output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def cleanup_files(files):
    """Delete temporary files."""
    for file in files:
        try:
            if os.path.exists(file):
                os.remove(file)
                print(f"Deleted temporary file: {file}")
        except Exception as e:
            print(f"Error deleting file {file}: {e}")

@app.post("/synthesize/")
async def synthesize(
    text: str = Form(...),
    model: str = Form(...)
):
    """
    Synthesizes speech from text using Piper and returns a WAV file.
    - `text`: The text to convert to speech.
    - `model`: The base name of the model (e.g., 'en_US-ryan-high').
    """
    print("Received text:", text)
    print("Received model:", model)

    try:
        # Construct paths to model and config files
        model_path = os.path.join(VOICE_DIR, f"{model}.onnx")
        config_path = os.path.join(VOICE_DIR, f"{model}.onnx.json")

        # Ensure the model and config files exist
        if not os.path.exists(model_path) or not os.path.exists(config_path):
            raise HTTPException(
                status_code=404,
                detail=f"Model or config not found for '{model}'"
            )

        # Generate a unique output filename
        output_filename = f"{uuid.uuid4()}.wav"
        output_wav = os.path.join(OUTPUT_DIR, output_filename)

        # Run Piper to generate WAV file
        process = subprocess.run(
            [
                "piper",
                "-m", model_path,
                "--config", config_path,
                "--output-file", output_wav
            ],
            input=text.encode('utf-8'),
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE
        )

        # Check for errors
        if process.returncode != 0:
            error_message = process.stderr.decode('utf-8', errors='ignore')
            print("Piper error:", error_message)
            raise HTTPException(
                status_code=500,
                detail=f"Piper error: {error_message}"
            )

        # Return the WAV file and clean up after sending
        return FileResponse(
            path=output_wav,
            media_type="audio/wav",
            filename=os.path.basename(output_wav),
            background=BackgroundTask(cleanup_files, [output_wav])
        )

    except Exception as e:
        print("Exception occurred:", str(e))
        raise HTTPException(status_code=500, detail=str(e))
