# Quantum Drone Pilot ⚛️🚁

**Interactive 3D Quantum Computing Visualization for Cybersecurity Education**

Fly your drone through real quantum cryptography protocols and algorithms! Experience quantum cybersecurity from the inside with first-person 3D visualization of quantum states, eavesdropping attacks, and quantum advantage.

![Quantum Drone Pilot](https://img.shields.io/badge/Quantum-Computing-blue) ![Godot](https://img.shields.io/badge/Godot-4.3-blue) ![Python](https://img.shields.io/badge/Python-FastAPI-green) ![Qiskit](https://img.shields.io/badge/Qiskit-Aer-purple)

## 🎯 What Makes This Special

- **First-Person Quantum Flight**: Pilot your drone through live quantum simulations using WASD+mouse controls
- **Real Quantum Computing**: Powered by Qiskit Aer simulator - authentic quantum mechanics, not just animations
- **Cybersecurity Focus**: Experience BB84 quantum key distribution and Grover's search algorithm attacks
- **Live Visualization**: Watch quantum states evolve in real-time as spheres change color (phase) and size (probability)
- **Interactive Eavesdropping**: Toggle Eve attacks and see quantum security protocols detect intrusions
- **Quantum Advantage**: Witness Grover's algorithm outperform classical search with rising probability mountains

## 🚀 Quick Start

### Prerequisites
- Python 3.8+ with pip
- Godot 4.3+ engine
- Windows/Linux/macOS

### 1. Start the Quantum Backend
```bash
cd quantum-drone-pilot-v1/backend
pip install -r requirements.txt
./run.sh  # On Windows: python main.py
```
**Backend runs on http://localhost:8000**

### 2. Launch Godot Frontend
1. Open Godot 4.3+
2. Import project: `quantum-drone-pilot-v1/godot/project.godot`
3. Press F5 to run project
4. Navigate: **MainMenu** → **Protocols/Algorithms** → **Choose Mission**

## 🎮 Mission Controls

### BB84 Quantum Key Distribution
- **WASD + Mouse**: First-person drone flight
- **E Key**: Toggle Eve eavesdropping attack
- **SPACE**: Measure quantum bits
- **ESC**: Exit to main menu

**What to Watch:**
- 3 quantum spheres pulse and change colors (quantum phases)
- Error rate increases when Eve is active (orange/red warnings)
- "Eve: DETECTED!" alerts when quantum eavesdropping is caught
- Sifted key accumulates as secure bits are generated

### Grover's Search Algorithm
- **WASD + Mouse**: First-person drone flight around database
- **SPACE**: Perform final database measurement
- **ESC**: Exit to main menu

**What to Watch:**
- 8 database items arranged in a 2×4 grid
- Target item (red) grows taller as quantum algorithm finds it
- Success probability rises from 12.5% (classical) to 90%+ (quantum)
- Quantum advantage demonstrated visually as "rising mountains"

## 🏗️ Architecture

```
┌─────────────────┐    HTTP/JSON     ┌──────────────────┐
│   Godot 4.3     │ ←── 200ms ────→ │  FastAPI Backend │
│   Frontend      │    Polling       │   (Port 8000)    │
├─────────────────┤                  ├──────────────────┤
│ • 3D Graphics   │                  │ • Qiskit Aer     │
│ • First-Person  │                  │ • BB84 Protocol  │
│ • Real-time HUD │                  │ • Grover Search  │
│ • Mission Flow  │                  │ • Quantum Engine │
└─────────────────┘                  └──────────────────┘
```

### Tech Stack
- **Frontend**: Godot 4.3+ (GDScript, Forward+ renderer)
- **Backend**: FastAPI + Uvicorn (Python 3.8+)
- **Quantum**: Qiskit Aer StatevectorSimulator (100% offline)
- **Communication**: HTTP REST API with 200ms polling
- **Visualization**: Real-time 3D quantum state rendering

## 📁 Project Structure

```
quantum-drone-pilot-v1/
├── backend/
│   ├── main.py              # FastAPI server entry point
│   ├── models.py            # Pydantic data models
│   ├── quantum_engine.py    # Qiskit integration layer
│   └── simulators/
│       ├── base.py          # Abstract mission simulator
│       ├── bb84.py          # BB84 protocol (146 lines)
│       └── grover.py        # Grover algorithm (146 lines)
└── godot/
    ├── scenes/              # Godot scene files (.tscn)
    ├── scripts/
    │   ├── GameState.gd     # Global state management
    │   ├── MissionLoader.gd # Backend communication (163 lines)
    │   ├── QuantumUpdater.gd# 3D visualization (283 lines)
    │   ├── HUD.gd           # Head-up display (222 lines)
    │   └── DroneController.gd# First-person controls (58 lines)
    └── project.godot        # Godot project configuration
```

## 🎨 Screenshots & Features

### BB84 Quantum Key Distribution
- **Visual**: Three pulsing quantum spheres in triangular formation
- **Colors**: Phase-mapped HSV spectrum (red→orange→yellow→green→cyan→blue→purple)
- **Animation**: Spheres scale with measurement probabilities
- **Security**: Real-time error rate monitoring and Eve detection

### Grover's Search Algorithm
- **Visual**: 2×4 database grid with rising probability bars
- **Target**: Item 5 glows bright red and towers above others
- **Quantum Advantage**: Success rate climbs from 12.5% to 90%+
- **Iterations**: Watch 3 Grover iterations amplify the correct answer

## 🏆 Educational Value

### For Cybersecurity Students
- **Quantum Cryptography**: Experience BB84 protocol firsthand
- **Attack Scenarios**: See how quantum eavesdropping works
- **Detection Methods**: Learn how quantum mechanics provides security
- **Future Threats**: Understand Grover's impact on symmetric encryption

### For Quantum Computing Learners
- **Quantum Mechanics**: Visualize superposition, phase, and measurement
- **Algorithm Understanding**: See Grover's oracle and diffusion operators
- **Real Implementation**: Connected to actual Qiskit quantum simulator
- **Interactive Learning**: Hands-on exploration beats textbook theory

## 🔧 Development Commands

### Backend Development
```bash
# Install dependencies
pip install fastapi uvicorn qiskit qiskit-aer pydantic

# Run development server
uvicorn main:app --reload --port 8000

# Test API directly
curl http://localhost:8000/
curl -X POST http://localhost:8000/simulate -H "Content-Type: application/json" -d '{"mission_type":"bb84","action":"start","parameters":{}}'
```

### Frontend Development
```bash
# Run from Godot editor (F5) or command line:
godot --path quantum-drone-pilot-v1/godot

# Export for web/desktop from Godot Project Settings
```

## 📈 Performance Stats
- **Backend**: ~858 lines of Python (simplified for hackathon)
- **Frontend**: ~746 lines of GDScript (optimized for demos)
- **Total**: ~1,604 lines of code
- **Startup**: <3 seconds from launch to flying
- **Latency**: 200ms quantum state updates
- **Memory**: <100MB total (Godot + Python backend)

## 🎪 Demo Instructions

Perfect for **hackathons, classroom demos, and quantum computing presentations**:

1. **Setup** (30 seconds): Start backend, launch Godot
2. **BB84 Demo** (60 seconds): Show quantum spheres, toggle Eve attack, demonstrate detection
3. **Grover Demo** (60 seconds): Show database search, quantum advantage over classical
4. **Conclusion**: "Fly inside real quantum cybersecurity!"

## 🛡️ Security & Privacy
- **100% Offline**: No external quantum cloud services required
- **Local Simulation**: All quantum computing runs on your machine
- **No Data Collection**: Zero telemetry or user tracking
- **Open Source**: Full code transparency for security auditing

## 🙏 Acknowledgments
- **Qiskit**: IBM's quantum computing framework
- **Godot Engine**: Free and open-source game engine
- **FastAPI**: Modern Python web framework
- **BB84 Protocol**: Bennett & Brassard quantum cryptography
- **Grover's Algorithm**: Lov Grover's quantum search algorithm

## 📄 License
MIT License - See LICENSE file for details

## 🤝 Contributing
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-quantum-viz`)
3. Commit changes (`git commit -m 'Add amazing quantum visualization'`)
4. Push to branch (`git push origin feature/amazing-quantum-viz`)
5. Open Pull Request

---

**Quantum Drone Pilot** - *Where quantum physics meets cybersecurity in immersive 3D*

⚛️ Fly inside the quantum world 🚁