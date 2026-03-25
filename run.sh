#!/bin/bash

echo "🚀 Starting Quantum Drone Pilot Backend..."
echo "================================================"

# Navigate to backend directory
cd backend

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python -m venv venv
fi

# Activate virtual environment
echo "🔌 Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -r requirements.txt

# Start FastAPI server
echo "🌐 Starting FastAPI server on http://localhost:8000"
echo "================================================"
echo "✅ Backend ready! Press Ctrl+C to stop."
echo ""
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
