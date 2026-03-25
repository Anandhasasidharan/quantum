"""
FastAPI Backend for Quantum Drone Pilot.
Serves quantum simulation data to Godot frontend via HTTP REST API.
100% offline - uses only Qiskit Aer local simulator.
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from typing import Dict, Any, Optional
import uvicorn

from models import (
    SimulationRequest,
    SimulationResponse,
    MeasurementRequest,
    MeasurementResult,
    StatusResponse,
    ResetRequest,
    MissionType,
    QubitState,
    EntanglementLink
)
from simulators.base import QuantumMissionSimulator


# Create FastAPI app
app = FastAPI(
    title="Quantum Drone Pilot API",
    description="Backend API for quantum simulation visualization",
    version="1.0.0"
)

# Enable CORS for Godot frontend (running on different port)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow all origins for local development
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc.)
    allow_headers=["*"],  # Allow all headers
)

# Global state: active mission simulator
active_simulator: Optional[QuantumMissionSimulator] = None
current_mission_type: Optional[MissionType] = None


# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

def get_simulator_for_mission(mission_type: MissionType) -> QuantumMissionSimulator:
    """
    Factory function to create appropriate simulator for mission type.

    Args:
        mission_type: Type of quantum mission

    Returns:
        Initialized mission simulator

    Raises:
        HTTPException: If mission type not implemented yet
    """
    if mission_type == MissionType.BB84:
        # Import here to avoid circular imports
        from simulators.bb84 import BB84Simulator
        return BB84Simulator(num_qubits=12)  # Proper quantum cryptography scale

    elif mission_type == MissionType.GROVER:
        from simulators.grover import GroverSimulator
        return GroverSimulator()  # Now uses 6 qubits = 64 database items

    elif mission_type == MissionType.E91:
        from simulators.e91 import E91Simulator
        return E91Simulator(num_qubits=2)  # Entangled Bell pairs

    elif mission_type == MissionType.B92:
        from simulators.b92 import B92Simulator
        return B92Simulator(num_qubits=1)  # Simple 2-state protocol

    elif mission_type == MissionType.SHOR:
        from simulators.shor import ShorSimulator
        return ShorSimulator(num_qubits=6)  # Period-finding + QFT

    else:
        raise HTTPException(
            status_code=400,
            detail=f"Unknown mission type: {mission_type}"
        )


# ============================================================================
# API ENDPOINTS
# ============================================================================

@app.get("/")
async def root():
    """Health check endpoint"""
    return {
        "status": "online",
        "service": "Quantum Drone Pilot API",
        "version": "1.0.0",
        "quantum_backend": "Qiskit Aer (local)",
        "message": "Ready to simulate quantum worlds!"
    }


@app.get("/status", response_model=StatusResponse)
async def get_status():
    """
    Get current simulation status.
    Quick endpoint for health checks.
    """
    if active_simulator is None:
        return StatusResponse(
            active=False,
            mission_type=None,
            step=0,
            qubit_count=0
        )

    return StatusResponse(
        active=True,
        mission_type=current_mission_type,
        step=active_simulator.step_count,
        qubit_count=active_simulator.num_qubits
    )


@app.post("/simulate", response_model=SimulationResponse)
async def simulate(request: SimulationRequest) -> SimulationResponse:
    """
    Main simulation endpoint.
    Handles start, step, and continuous simulation updates.

    Args:
        request: Simulation parameters and action

    Returns:
        Current quantum state with visualization data
    """
    global active_simulator, current_mission_type

    try:
        # START: Initialize new simulation
        if request.action == "start":
            current_mission_type = request.mission_type
            active_simulator = get_simulator_for_mission(request.mission_type)
            active_simulator.initialize(request.parameters)

            message = f"Started {request.mission_type.value.upper()} mission"

        # STEP: Execute one simulation step
        elif request.action == "step":
            if active_simulator is None:
                raise HTTPException(
                    status_code=400,
                    detail="No active simulation. Use action='start' first."
                )

            # Prepare step parameters
            step_params = request.parameters.copy()
            if request.basis_choice:
                step_params['basis'] = request.basis_choice.value
            if request.eve_active:
                step_params['eve_active'] = True

            # Execute step
            active_simulator.step(step_params)
            message = f"Step {active_simulator.step_count} completed"

        # RESET: Clear current simulation
        elif request.action == "reset":
            if active_simulator:
                active_simulator.reset()
            message = "Simulation reset"

        else:
            raise HTTPException(
                status_code=400,
                detail=f"Unknown action: {request.action}. Use 'start', 'step', or 'reset'"
            )

        # Get visualization data
        viz_data = active_simulator.get_visualization_data()

        # Build response
        response = SimulationResponse(
            success=True,
            mission_type=current_mission_type,
            step=active_simulator.step_count,
            qubits=[QubitState(**q) for q in viz_data['qubits']],
            entanglements=[],  # Godot will calculate if needed
            measurements=[],
            mission_data=viz_data.get('mission_data', {}),
            message=message
        )

        return response

    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Simulation error: {str(e)}"
        )


@app.post("/measure", response_model=SimulationResponse)
async def measure(request: MeasurementRequest) -> SimulationResponse:
    """
    Measure specified qubits and return results.

    Args:
        request: Measurement parameters (qubits, basis)

    Returns:
        Updated quantum state after measurement
    """
    global active_simulator

    if active_simulator is None:
        raise HTTPException(
            status_code=400,
            detail="No active simulation. Start a mission first."
        )

    try:
        # Perform measurement
        basis = request.basis.value if request.basis else None
        measurement_data = active_simulator.measure(request.qubit_indices, basis)

        # Convert to MeasurementResult models
        measurements = [
            MeasurementResult(
                qubit_index=m['qubit'],
                result=m['result'],
                basis_used=m.get('basis', None)
            )
            for m in measurement_data
        ]

        # Get updated visualization
        viz_data = active_simulator.get_visualization_data()

        response = SimulationResponse(
            success=True,
            mission_type=current_mission_type,
            step=active_simulator.step_count,
            qubits=[QubitState(**q) for q in viz_data['qubits']],
            entanglements=[],
            measurements=measurements,
            mission_data=viz_data.get('mission_data', {}),
            message=f"Measured {len(request.qubit_indices)} qubit(s)"
        )

        return response

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Measurement error: {str(e)}"
        )


@app.post("/reset")
async def reset(request: ResetRequest):
    """
    Reset current simulation or switch to new mission.

    Args:
        request: Optional new mission type

    Returns:
        Status message
    """
    global active_simulator, current_mission_type

    if request.mission_type:
        # Start new mission
        current_mission_type = request.mission_type
        active_simulator = get_simulator_for_mission(request.mission_type)
        active_simulator.initialize({})
        message = f"Reset to {request.mission_type.value.upper()} mission"
    else:
        # Just reset current mission
        if active_simulator:
            active_simulator.reset()
            message = "Simulation reset"
        else:
            message = "No active simulation to reset"

    return {
        "success": True,
        "message": message,
        "mission_type": current_mission_type.value if current_mission_type else None
    }


@app.get("/mission/info")
async def get_mission_info():
    """
    Get information about current mission.

    Returns:
        Mission description, objectives, and current status
    """
    if active_simulator is None:
        raise HTTPException(
            status_code=400,
            detail="No active mission"
        )

    info = active_simulator.get_mission_info()
    circuit_info = active_simulator.get_circuit_info()

    return {
        **info,
        "circuit": circuit_info,
        "step": active_simulator.step_count
    }


@app.get("/missions/available")
async def get_available_missions():
    """
    List all available missions with categories.

    Returns:
        Dictionary of protocols and algorithms
    """
    return {
        "protocols": [
            {
                "id": "bb84",
                "name": "BB84 Protocol",
                "category": "defense",
                "description": "Quantum key distribution with eavesdropping detection",
                "status": "available",
                "qubits": 3
            },
            {
                "id": "e91",
                "name": "E91 Protocol",
                "category": "defense",
                "description": "Entanglement-based quantum key distribution",
                "status": "coming_soon",
                "qubits": 4
            }
        ],
        "algorithms": [
            {
                "id": "grover",
                "name": "Grover's Search",
                "category": "attack",
                "description": "Quantum database search with quadratic speedup",
                "status": "available",
                "qubits": 4
            },
            {
                "id": "shor",
                "name": "Shor's Algorithm",
                "category": "attack",
                "description": "Quantum integer factorization",
                "status": "coming_soon",
                "qubits": 5
            }
        ]
    }


# ============================================================================
# STARTUP
# ============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("QUANTUM DRONE PILOT - Backend Server")
    print("=" * 60)
    print("Quantum Engine: Qiskit Aer (100% offline)")
    print("Server: http://localhost:8000")
    print("API Docs: http://localhost:8000/docs")
    print("=" * 60)

    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,  # Auto-reload on code changes
        log_level="info"
    )
