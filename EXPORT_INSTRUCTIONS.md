# 📦 Export Instructions - Quantum Drone Pilot

**Create portable builds for hackathon demonstrations and distribution**

---

## 🌐 HTML5 Web Export (Recommended for Demos)

### 1. Setup Web Export Template
1. **Open Godot Editor** with the project loaded
2. Go to **Project** → **Export...**
3. Click **Add...** → Select **Web**
4. If prompted, **Download and Install** Web export templates

### 2. Configure Web Export
- **Name**: `Quantum Drone Pilot - Web`
- **Export Path**: `exports/web/quantum-drone-pilot.html`
- **Custom HTML Shell**: Leave blank (use default)
- **Head Include**: Add if needed for analytics

### 3. Important Web Settings
```
Variant: release
Custom Template: (leave blank)
Encryption: Disabled
Options:
  ├── Custom HTML Shell: (default)
  ├── Head Include:
  └── Style Include:
```

### 4. Export Process
1. Click **Export Project**
2. Choose export folder: `quantum-drone-pilot-v1/exports/web/`
3. Filename: `index.html`
4. Click **Save**

### 5. Web Deployment
```bash
# Start simple HTTP server for testing
cd quantum-drone-pilot-v1/exports/web/
python -m http.server 8080

# Open browser to http://localhost:8080
```

### ⚠️ Web Export Limitations
- **Backend Connection**: Web build cannot access localhost backend
- **CORS Issues**: Browser security blocks local HTTP requests
- **Solution**: Deploy both frontend and backend to same cloud service, or use desktop export for full functionality

---

## 🖥️ Desktop Export (Full Functionality)

### Windows Export

#### Setup
1. **Project** → **Export...**
2. **Add...** → **Windows Desktop**
3. Download export templates if prompted

#### Configuration
```
Export Path: exports/windows/quantum-drone-pilot.exe
Options:
  ├── Executable: quantum-drone-pilot.exe
  ├── Icon: res://icon.ico (if available)
  ├── Company Name: Your Name
  ├── Product Name: Quantum Drone Pilot
  ├── File Version: 1.0.0.0
  └── Product Version: 1.0.0.0
```

#### Export
1. **Export Project** → Choose `exports/windows/`
2. Creates `quantum-drone-pilot.exe`

### Linux Export

#### Setup
1. **Add...** → **Linux/X11**
2. **Export Path**: `exports/linux/quantum-drone-pilot`

#### Configuration
```
Options:
  ├── Executable: quantum-drone-pilot
  └── Debug: Disabled (for release)
```

### macOS Export

#### Setup
1. **Add...** → **macOS**
2. **Export Path**: `exports/macos/quantum-drone-pilot.app`

#### Configuration
```
Options:
  ├── Bundle Identifier: com.yourname.quantum-drone-pilot
  ├── App Name: Quantum Drone Pilot
  └── Code Sign: (optional, for distribution)
```

---

## 📱 Hackathon Distribution Package

### Complete Portable Package
Create a single folder with everything needed:

```
quantum-drone-pilot-hackathon/
├── 📁 backend/
│   ├── 📄 run.sh
│   ├── 📄 main.py
│   ├── 📄 requirements.txt
│   └── 📁 simulators/
├── 📁 desktop-builds/
│   ├── 📁 windows/
│   │   └── 📄 quantum-drone-pilot.exe
│   ├── 📁 linux/
│   │   └── 📄 quantum-drone-pilot
│   └── 📁 macos/
│       └── 📁 quantum-drone-pilot.app/
├── 📁 web-build/
│   ├── 📄 index.html
│   ├── 📄 quantum-drone-pilot.js
│   ├── 📄 quantum-drone-pilot.wasm
│   └── 📄 quantum-drone-pilot.pck
├── 📄 README.md
├── 📄 DEMO_SCRIPT.md
└── 📄 START_HERE.txt
```

### START_HERE.txt Content
```
🚀 Quantum Drone Pilot - Hackathon Demo Package

QUICK START (3 steps):
1. Start backend: cd backend && ./run.sh
2. Run desktop build: desktop-builds/windows/quantum-drone-pilot.exe
3. Fly through quantum protocols!

DEMO SCRIPT: See DEMO_SCRIPT.md for 90-second presentation flow

REQUIREMENTS:
- Python 3.8+ (for backend)
- Backend must run first on localhost:8000
- Desktop builds have full functionality
- Web build is for reference only (CORS limitations)

CONTROLS:
- WASD + Mouse: Fly drone
- E: Toggle Eve attack (BB84 only)
- SPACE: Measure qubits
- ESC: Exit mission

MISSIONS:
- MainMenu → Protocols → BB84 (Quantum cryptography)
- MainMenu → Algorithms → Grover (Quantum search)

Built with Qiskit + Godot | 100% offline quantum simulation
```

---

## 🎯 Single-File Solutions

### Godot PCK Bundling
For ultra-portable single executable:

1. **Project Settings** → **Application** → **Config**
2. **Use Custom User Dir**: Enable
3. **Custom User Dir Name**: `quantum_drone_pilot`

### Python Backend Bundling (Optional)
```bash
# Create standalone Python executable
pip install pyinstaller
pyinstaller --onefile --name quantum-backend main.py

# Results in single quantum-backend.exe file
```

---

## 🔧 Build Automation Script

### build_all.py
```python
#!/usr/bin/env python3
import os
import subprocess
import shutil

def export_godot_project():
    """Export Godot project for all platforms"""
    platforms = [
        ("Windows Desktop", "windows", "quantum-drone-pilot.exe"),
        ("Linux/X11", "linux", "quantum-drone-pilot"),
        ("Web", "web", "index.html")
    ]

    for platform, folder, filename in platforms:
        export_path = f"exports/{folder}/{filename}"
        print(f"Exporting {platform}...")
        # Add Godot command-line export here
        # godot --export platform export_path

def create_distribution():
    """Create complete hackathon distribution package"""
    dist_dir = "quantum-drone-pilot-hackathon"

    # Copy backend
    shutil.copytree("backend", f"{dist_dir}/backend")

    # Copy exports
    shutil.copytree("exports", f"{dist_dir}/desktop-builds")

    # Copy documentation
    shutil.copy("README.md", dist_dir)
    shutil.copy("DEMO_SCRIPT.md", dist_dir)

    print(f"Distribution package created: {dist_dir}/")

if __name__ == "__main__":
    export_godot_project()
    create_distribution()
```

---

## 📋 Pre-Demo Checklist

### Before Hackathon Presentation
- [ ] Backend tested and starts in <10 seconds
- [ ] Desktop build tested on target platform
- [ ] Web build uploaded (if using cloud demo)
- [ ] Demo script practiced (90 seconds total)
- [ ] Backup builds available (USB drive)
- [ ] Screen recording as final backup

### Demo Day Setup
- [ ] Python 3.8+ installed on demo machine
- [ ] All ports (8000, 8080) available
- [ ] Firewall allows local connections
- [ ] External monitor/projector tested
- [ ] Audio working (for background music)

---

**📦 Export Complete - Ready for Hackathon Deployment!**

*For questions or issues, refer to Godot export documentation or create GitHub issue.*