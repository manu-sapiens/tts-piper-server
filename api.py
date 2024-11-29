from fastapi import FastAPI, HTTPException, Form
from fastapi.responses import FileResponse
from starlette.background import BackgroundTask
import subprocess
import os
import uuid
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

app = FastAPI()

# Directories for voices and output
VOICE_DIR = "/piper/voices"
OUTPUT_DIR = "/piper/output"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Get the default voice model from environment variable
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL")

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
    model: str = Form(None)  # Make model optional
):
    """
    Synthesizes speech from text using Piper and returns a WAV file.
    - `text`: The text to convert to speech.
    - `model`: (Optional) The base name of the model (e.g., 'en_US-ryan-high'). Uses default if not provided.
    """
    if not model:
        if DEFAULT_MODEL:
            model = DEFAULT_MODEL  # Use default model from .env
            print(f"No model provided. Using default model from .env: {model}")
        else:
            # Handle case where DEFAULT_MODEL is not set
            raise HTTPException(
                status_code=500,
                detail="No default model specified and no model provided."
            )
    else:
        print(f"Received model: {model}")

    print(f"Received text: {text}")

    try:
        # Construct paths to model and config files
        model_path = os.path.join(VOICE_DIR, f"{model}.onnx")
        # Try both hyphen and underscore variants for config
        config_path = os.path.join(VOICE_DIR, f"{model}.onnx.json")
        config_path_alt = os.path.join(VOICE_DIR, f"{model.replace('-', '_')}.onnx.json")

        print(f"Model path: {model_path}")
        print(f"Config path: {config_path}")
        print(f"Alternative config path: {config_path_alt}")

        # Check model file
        if not os.path.exists(model_path):
            raise HTTPException(
                status_code=404,
                detail=f"Model file not found: '{model}.onnx'"
            )
        
        # Try both config file variants
        if os.path.exists(config_path):
            use_config_path = config_path
        elif os.path.exists(config_path_alt):
            use_config_path = config_path_alt
        else:
            raise HTTPException(
                status_code=404,
                detail=f"Config file not found for '{model}'"
            )

        # Generate a unique output filename
        output_filename = f"{uuid.uuid4()}.wav"
        output_wav = os.path.join(OUTPUT_DIR, output_filename)

        # Run Piper to generate WAV file
        process = subprocess.run(
            [
                "piper",
                "-m", model_path,
                "--config", use_config_path,
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

# Existing /voices/ endpoint remains unchanged
@app.get("/voices/")
async def list_voices():
    """
    Returns a list of available voice models.
    """
    try:
        # List all .onnx files in the VOICE_DIR
        voice_files = [f for f in os.listdir(VOICE_DIR) if f.endswith('.onnx')]
        # Extract the base names of the models
        voices = [os.path.splitext(f)[0] for f in voice_files]
        # Remove any duplicates and sort the list
        voices = sorted(set(voices))
        return {"voices": voices}
    except Exception as e:
        print("Exception occurred while listing voices:", str(e))
        raise HTTPException(status_code=500, detail=str(e))
