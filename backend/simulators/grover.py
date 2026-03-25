"""
Grover's Algorithm Simulator
Quantum search algorithm for unstructured databases
"""

import numpy as np
from typing import Dict, List, Any, Optional
import math
from qiskit import QuantumCircuit

from .base import QuantumMissionSimulator

class GroverSimulator(QuantumMissionSimulator):
    """Grover's algorithm for quantum database search."""

    def __init__(self):
        super().__init__(num_qubits=6)  # 64 database items (0-63)
        self.num_items = 2 ** self.num_qubits
        self.marked_item = np.random.randint(0, self.num_items)  # Random search target
        self.current_iteration = 0
        # Optimal iterations ≈ π/4 * sqrt(N) ≈ 2.2 for N=8
        self.max_iterations = 3

    def initialize(self, parameters: Dict[str, Any]) -> None:
        """Initialize Grover search."""
        self.engine.reset(self.num_qubits)
        self.step_count = 0
        self.current_iteration = 0

        # Set target item if provided
        if 'target_item' in parameters:
            self.marked_item = parameters['target_item']

        # Initialize superposition state
        circuit = QuantumCircuit(self.num_qubits)
        for qubit in range(self.num_qubits):
            circuit.h(qubit)

        self.engine.apply_circuit(circuit)

        # Update mission state
        self.mission_state = {
            "target_item": self.marked_item,
            "iteration": 0,
            "success_probability": 1.0 / self.num_items,
            "algorithm": "grover",
            "database_items": self._get_database_probabilities()
        }

    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute one Grover iteration."""
        if self.current_iteration < self.max_iterations:
            # Apply oracle + diffusion
            self._apply_grover_iteration()
            self.current_iteration += 1
        else:
            # Reset for continuous demo
            self.current_iteration = 0
            self.initialize({})
            return self.mission_state

        self.step_count += 1

        # Update probabilities
        database_items = self._get_database_probabilities()
        success_prob = database_items[self.marked_item]["probability"]

        self.mission_state.update({
            "iteration": self.current_iteration,
            "success_probability": success_prob,
            "database_items": database_items
        })

        return self.mission_state

    def _apply_grover_iteration(self):
        """Apply one Grover iteration (oracle + diffusion)."""
        circuit = QuantumCircuit(self.num_qubits)

        # Oracle: mark target item (item 5 = |101⟩)
        circuit.x(1)  # Flip qubit 1 (middle bit is 0 in |101⟩)
        circuit.ccz(0, 1, 2)  # Multi-controlled Z
        circuit.x(1)  # Unflip

        # Diffusion: inversion about average
        # Transform to |000⟩ basis
        for qubit in range(self.num_qubits):
            circuit.h(qubit)

        # Mark |000⟩
        for qubit in range(self.num_qubits):
            circuit.x(qubit)

        circuit.ccz(0, 1, 2)  # Multi-controlled Z

        # Restore
        for qubit in range(self.num_qubits):
            circuit.x(qubit)
            circuit.h(qubit)

        self.engine.apply_circuit(circuit)

    def _get_database_probabilities(self) -> List[Dict[str, Any]]:
        """Get current probability distribution over database items."""
        statevector = self.engine.get_statevector()
        probabilities = np.abs(statevector) ** 2

        database_items = []
        for i in range(self.num_items):
            database_items.append({
                "id": i,
                "probability": float(probabilities[i]),
                "is_target": i == self.marked_item,
                "binary": format(i, f'0{self.num_qubits}b')
            })

        return database_items

    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """Measure qubits (final database lookup)."""
        results = []

        for qubit_idx in qubit_indices:
            if 0 <= qubit_idx < self.num_qubits:
                result = self.engine.measure_qubit(qubit_idx)
                results.append({
                    'qubit': qubit_idx,
                    'result': result,
                    'basis': 'computational'
                })

        # Update state after measurement
        database_items = self._get_database_probabilities()
        self.mission_state["database_items"] = database_items

        return results

    def get_mission_info(self) -> Dict[str, Any]:
        """Get mission information."""
        return {
            "name": "Grover's Search Algorithm",
            "description": "Quantum search through unstructured database",
            "objective": f"Find marked item {self.marked_item} in {self.num_items}-item database",
            "qubits": self.num_qubits,
            "iterations": f"{self.current_iteration}/{self.max_iterations}",
            "speedup": "Quadratic over classical search"
        }