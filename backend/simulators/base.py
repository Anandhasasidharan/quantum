"""
Abstract base class for quantum mission simulators.
All mission types (BB84, E91, Grover, Shor) inherit from this.
"""

from abc import ABC, abstractmethod
from typing import Dict, Any, List, Optional
from quantum_engine import QuantumEngine


class QuantumMissionSimulator(ABC):
    """
    Base class for all quantum mission simulators.
    Each mission implements specific quantum protocols or algorithms.
    """

    def __init__(self, num_qubits: int):
        """
        Initialize the mission simulator.

        Args:
            num_qubits: Number of qubits for this mission
        """
        self.num_qubits = num_qubits
        self.engine = QuantumEngine(num_qubits)
        self.step_count = 0
        self.mission_state: Dict[str, Any] = {}

    @abstractmethod
    def initialize(self, parameters: Dict[str, Any]) -> None:
        """
        Initialize the quantum circuit for this mission.

        Args:
            parameters: Mission-specific initialization parameters
        """
        pass

    @abstractmethod
    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """
        Execute one simulation step and return visualization data.

        Args:
            parameters: Step-specific parameters

        Returns:
            Dictionary with mission-specific data for visualization
        """
        pass

    @abstractmethod
    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """
        Measure specified qubits.

        Args:
            qubit_indices: List of qubit indices to measure
            basis: Optional measurement basis (for QKD protocols)

        Returns:
            List of measurement results with metadata
        """
        pass

    def reset(self) -> None:
        """Reset the simulation to initial state"""
        self.engine.reset(self.num_qubits)
        self.step_count = 0
        self.mission_state = {}

    def get_visualization_data(self) -> Dict[str, Any]:
        """
        Get current quantum state for visualization.

        Returns:
            Dictionary with qubit states and mission data
        """
        qubits = self.engine.get_qubit_states()

        return {
            'qubits': qubits,
            'step': self.step_count,
            'mission_data': self.mission_state
        }

    @abstractmethod
    def get_mission_info(self) -> Dict[str, Any]:
        """
        Get mission-specific information for HUD display.

        Returns:
            Dictionary with mission name, description, objectives, etc.
        """
        pass

    def get_circuit_info(self) -> Dict[str, str]:
        """
        Get information about current quantum circuit.

        Returns:
            Dictionary with circuit depth and diagram
        """
        return {
            'depth': self.engine.get_circuit_depth(),
            'diagram': self.engine.get_circuit_diagram()
        }
