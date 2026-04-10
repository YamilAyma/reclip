#!/bin/bash
set -e
cd "$(dirname "$0")"

# Check prerequisites
missing=""

if command -v python3 &> /dev/null; then
    PYTHON="python3"
elif command -v python &> /dev/null; then
    PYTHON="python"
else
    missing="$missing python"
fi

if ! command -v yt-dlp &> /dev/null; then
    missing="$missing yt-dlp"
fi

if ! command -v ffmpeg &> /dev/null; then
    missing="$missing ffmpeg"
fi

if [ -n "$missing" ]; then
    echo "Missing required tools:$missing"
    echo ""
    if [[ "$OSTYPE" == "msys"* || "$OSTYPE" == "cygwin"* ]]; then
        echo "Please install missing tools via your Windows package manager (e.g. winget or scoop)."
    elif command -v brew &> /dev/null; then
        echo "Install with:  brew install$missing"
    elif command -v apt &> /dev/null; then
        echo "Install with:  sudo apt install$missing"
    else
        echo "Please install:$missing"
    fi
    exit 1
fi

# Detect activate script
if [ -f "venv/bin/activate" ]; then
    ACTIVATE="venv/bin/activate"
elif [ -f "venv/Scripts/activate" ]; then
    ACTIVATE="venv/Scripts/activate"
fi

# Set up venv and install Python deps
if [ ! -d "venv" ]; then
    echo "Setting up virtual environment..."
    $PYTHON -m venv venv
fi

if [ -f "venv/bin/activate" ]; then ACTIVATE="venv/bin/activate"; else ACTIVATE="venv/Scripts/activate"; fi
source "$ACTIVATE"

echo "Ensuring dependencies are installed..."
python -m pip install -q -r requirements.txt

PORT="${PORT:-8899}"
export PORT

echo ""
echo "  ReClip is running at http://localhost:$PORT"
echo ""
python app.py
