#!/bin/bash

echo "========================================"
echo "  Chatterbox TTS - Installation Setup for Linux"
echo "========================================"
echo
echo "This will install Chatterbox TTS in a virtual environment"
echo "to keep it isolated from other Python projects."
echo
echo "Requirements:"
echo "- Python 3.10 or higher"
echo "- NVIDIA GPU with CUDA support (recommended)"
echo "- Git (if you want to pull updates)"
echo
echo "Current directory: $(pwd)"
echo
read -p "Press Enter to continue..."

echo
echo "[1/8] Checking Python installation..."
PYTHON_EXEC=""
if command -v python3 &> /dev/null
then
    PYTHON_EXEC="python3"
elif command -v python &> /dev/null
then
    PYTHON_EXEC="python"
fi

if [ -z "$PYTHON_EXEC" ]
then
    echo "ERROR: Python 3.10+ is not installed or not in PATH"
    echo "Please install Python 3.10+"
    exit 1
fi
$PYTHON_EXEC --version

echo
echo "[2/8] Checking if we're in the correct directory..."
if [ ! -f "pyproject.toml" ]; then
    echo "ERROR: pyproject.toml not found!"
    echo "Please make sure you're running this from the chatterbox repository root."
    exit 1
fi

if [ ! -d "src/chatterbox" ]; then
    echo "ERROR: src/chatterbox directory not found!"
    echo "Please make sure you're in the correct chatterbox repository."
    exit 1
fi

echo "Repository structure verified ✓"

echo
echo "[3/8] Creating virtual environment..."
if [ -d "venv" ]; then
    echo "Virtual environment already exists. Removing old one..."
    rm -rf venv
fi
$PYTHON_EXEC -m venv venv

echo
echo "[4/8] Activating virtual environment..."
source venv/bin/activate

echo
echo "[5/8] Upgrading pip..."
$PYTHON_EXEC -m pip install --upgrade pip

echo
echo "[6/8] Installing PyTorch (2.6.0)..."
echo "This installs the CPU wheels by default. For CUDA builds, swap to the matching +cuXXX wheels from https://download.pytorch.org/whl/cu124"
pip install torch==2.6.0 torchaudio==2.6.0

echo
echo "[7/8] Installing Chatterbox TTS and dependencies..."
pip install -r requirements.txt
pip install -e .

echo
echo "[8/8] Testing installation..."
echo "Testing PyTorch and CUDA..."
$PYTHON_EXEC -c "import torch; print('PyTorch version:', torch.__version__); print('CUDA available:', torch.cuda.is_available())"

if [ $? -ne 0 ]; then
    echo "WARNING: PyTorch test failed. Please verify your Python and CUDA setup."
fi

echo
echo "Testing Chatterbox import..."
$PYTHON_EXEC -c "from chatterbox.tts import ChatterboxTTS; print('Chatterbox TTS imported successfully!')"

if [ $? -ne 0 ]; then
    echo "WARNING: Chatterbox import failed. This might be a dependency issue."
    echo "The installation will continue, but you may need to troubleshoot."
fi

echo
echo "========================================"
echo "        Installation Complete!"
echo "========================================"
echo
echo "Virtual environment created at: $(pwd)/venv"
echo

echo "Final system check..."
$PYTHON_EXEC -c "import torch; print('GPU:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'None')"

echo
echo "========================================"
echo "           Ready for Audiobooks!"
echo "========================================"
echo
echo "To start Chatterbox TTS:"
echo "1. Run ./launch_audiobook.sh (recommended)"
echo "2. Or manually: source venv/bin/activate then python gradio_tts_app_audiobook.py"
echo
deactivate
echo "Installation finished successfully!"
