"""
Pydantic models for API request/response validation.
All data structures for communication between Godot frontend and FastAPI backend.
"""

from pydantic import BaseModel, Field
from typing import List, Dict, Optional, Any
from enum import Enum


class MissionType(str, Enum):
    """Available mission types"""
    BB84 = "bb84"
    E91 = "e91"
    B92 = "b92"
    GROVER = "grover"
    SHOR = "shor"


class BasisChoice(str, Enum):
    """Basis choices for QKD protocols"""
    RECTILINEAR = "rectilinear"  # |0⟩, |1⟩
    DIAGONAL = "diagonal"         # |+⟩, |-⟩


class QubitState(BaseModel):
    """Represents a single qubit's quantum state (pure quantum data)"""
    id: int = Field(..., description="Qubit index")
    amplitude: complex = Field(..., description="Complex amplitude")
    phase: float = Field(..., description="Phase angle in radians")
    probability: float = Field(..., description="Measurement probability")
    measured: bool = Field(default=False, description="Whether qubit has been measured")
    measurement_result: Optional[int] = Field(default=None, description="0 or 1 if measured")


class EntanglementLink(BaseModel):
    """Represents entanglement between two qubits"""
    qubit_a: int = Field(..., description="First qubit index")
    qubit_b: int = Field(..., description="Second qubit index")
    strength: float = Field(..., description="Entanglement strength [0-1]")
    phase: float = Field(..., description="Phase for pulsing animation")


class SimulationRequest(BaseModel):
    """Request to start or update a quantum simulation"""
    mission_type: MissionType = Field(..., description="Type of quantum mission")
    action: str = Field(default="step", description="Action: 'start', 'step', 'reset'")
    parameters: Dict[str, Any] = Field(default_factory=dict, description="Mission-specific parameters")

    # QKD-specific parameters
    basis_choice: Optional[BasisChoice] = Field(default=None, description="Basis for QKD measurement")
    eve_active: bool = Field(default=False, description="Whether Eve is eavesdropping")

    # Algorithm-specific parameters
    target_value: Optional[int] = Field(default=None, description="Target for Grover's search")
    number_to_factor: Optional[int] = Field(default=None, description="Number for Shor's algorithm")


class MeasurementRequest(BaseModel):
    """Request to measure specific qubits"""
    mission_type: MissionType = Field(..., description="Current mission type")
    qubit_indices: List[int] = Field(..., description="List of qubit indices to measure")
    basis: Optional[BasisChoice] = Field(default=None, description="Measurement basis for QKD")


class MeasurementResult(BaseModel):
    """Result of qubit measurement"""
    qubit_index: int = Field(..., description="Measured qubit index")
    result: int = Field(..., description="Measurement outcome (0 or 1)")
    basis_used: Optional[str] = Field(default=None, description="Basis used for measurement")


class SimulationResponse(BaseModel):
    """Response containing current quantum state visualization data"""
    success: bool = Field(..., description="Whether operation succeeded")
    mission_type: MissionType = Field(..., description="Current mission type")
    step: int = Field(default=0, description="Current simulation step/iteration")

    # Quantum state visualization
    qubits: List[QubitState] = Field(default_factory=list, description="All qubit states")
    entanglements: List[EntanglementLink] = Field(default_factory=list, description="Entanglement links")

    # Measurement results
    measurements: List[MeasurementResult] = Field(default_factory=list, description="Recent measurements")

    # Mission-specific data
    mission_data: Dict[str, Any] = Field(default_factory=dict, description="Mission-specific info")

    # Status messages
    message: str = Field(default="", description="Human-readable status message")
    error: Optional[str] = Field(default=None, description="Error message if any")


class StatusResponse(BaseModel):
    """Quick status check response"""
    active: bool = Field(..., description="Whether simulation is active")
    mission_type: Optional[MissionType] = Field(default=None, description="Current mission")
    step: int = Field(default=0, description="Current step")
    qubit_count: int = Field(default=0, description="Number of qubits")


class ResetRequest(BaseModel):
    """Request to reset simulation"""
    mission_type: Optional[MissionType] = Field(default=None, description="Mission to reset to")
