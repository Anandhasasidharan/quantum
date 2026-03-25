## Godot Project Test Instructions

### 1. Test Navigation Flow
1. Open Godot 4.3+
2. Import project: godot/project.godot
3. Run project (F5)
4. Expected: MainMenu loads with "QUANTUM DRONE PILOT" title
5. Click "🛡️ PROTOCOLS" → Should load ProtocolsHangar
6. Click "BB84 Protocol" → "LAUNCH MISSION" → Should load DroneMission
7. WASD + Mouse should move drone camera
8. ESC should return to MainMenu

### 2. Test Backend Integration (with backend running)
1. Start backend: cd quantum-drone-pilot-v1 && ./run.sh
2. Run Godot project
3. MainMenu should show "Backend: Online ✓"
4. Launch BB84 mission
5. HUD should show live quantum data updates every 200ms
6. Press E to toggle Eve (should update HUD)

### 3. Expected DroneMission Scene
- First-person camera view
- 3 glowing qubit spheres positioned in triangle
- HUD overlay with quantum statistics
- Smooth WASD movement + mouse look
- Controls hint at bottom of screen

### Files Created: 15 total
- 4 scenes (.tscn)
- 9 scripts (.gd)
- 1 environment (.tres)
- 1 icon (.svg)
- 397 lines of GDScript code