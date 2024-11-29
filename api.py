from fastapi import FastAPI, HTTPException, Form
from fastapi.responses import FileResponse
import subprocess
import os
import uuid

app = FastAPI()

# Directories for voices and output
VOICE_DIR = "/piper/voices"
OUTPUT_DIR = "/piper/output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

@app.post("/synthesize/")
async def synthesize(text: str = Form(...), model: str = Form(...)):
    """
    Synthesizes speech from text using Piper.
    - `text`: The text to convert to speech.
    - `model`: The base name of the model (e.g., 'en_US-ryan-high').
    """

    # Debugging input data
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
        output_file = os.path.join(OUTPUT_DIR, f"{uuid.uuid4()}.raw")

        # Run piper to generate the audio
        process = subprocess.run(
            [
                "piper",
                "-m", model_path,
                "--config", config_path,
                "--output-raw"
            ],
            input=text.encode('utf-8'),  # Encode input text to bytes
            stdout=subprocess.PIPE,      # Capture raw audio (bytes)
            stderr=subprocess.PIPE       # Capture errors (bytes)
        )

        # Log stdout and stderr for debugging
        print("Subprocess return code:", process.returncode)
        print("Subprocess STDOUT length:", len(process.stdout))
        print("Subprocess STDERR:", process.stderr.decode('utf-8', errors='ignore'))

        # Check for errors
        if process.returncode != 0:
            raise HTTPException(
                status_code=500,
                detail=f"Piper error: {process.stderr.decode('utf-8', errors='ignore')}"
            )

        # Save raw audio output to a file
        with open(output_file, "wb") as f:
            f.write(process.stdout)

        return FileResponse(output_file, media_type="audio/raw")

    except Exception as e:
        # Log the exception for debugging
        print("Exception occurred:", str(e))
        raise HTTPException(status_code=500, detail=str(e))
