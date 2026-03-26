"""
Quantum Engine - Simplified Qiskit Aer integration for hackathon.
Pure quantum logic, no 3D visualization concerns.
"""

import numpy as np
from typing import List, Dict, Any, Optional
from qiskit import QuantumCircuit, QuantumRegister, ClassicalRegister
from qiskit_aer import AerSimulator
from qiskit.quantum_info import Statevector


class QuantumEngine:
    """Manages quantum circuits using Qiskit Aer StatevectorSimulator (100% offline)."""

    def __init__(self, num_qubits: int = 3):
        self.num_qubits = num_qubits
        self.qreg = QuantumRegister(num_qubits, 'q')
        self.creg = ClassicalRegister(num_qubits, 'c')
        self.circuit = QuantumCircuit(self.qreg, self.creg)
        self.simulator = AerSimulator(method='statevector')
        self.statevector: Optional[Statevector] = None

    def reset(self, num_qubits: Optional[int] = None):
        """Reset to |0...0⟩ state."""
        if num_qubits is not None:
            self.num_qubits = num_qubits
        self.qreg = QuantumRegister(self.num_qubits, 'q')
        self.creg = ClassicalRegister(self.num_qubits, 'c')
        self.circuit = QuantumCircuit(self.qreg, self.creg)
        self.statevector = None

    def apply_circuit(self, new_circuit: QuantumCircuit):
        """Apply a quantum circuit to the current state."""
        # Compose the new circuit with the existing one
        self.circuit = self.circuit.compose(new_circuit)
        # Reset statevector so it gets recalculated
        self.statevector = None

    def get_statevector(self) -> Statevector:
        """Execute circuit and return statevector."""
        try:
            circuit_copy = self.circuit.remove_final_measurements(inplace=False)
            if circuit_copy.size() == 0:
                self.statevector = Statevector.from_label('0' * self.num_qubits)
                return self.statevector

            job = self.simulator.run(circuit_copy)
            result = job.result()
            self.statevector = Statevector(result.get_statevector())
            return self.statevector
        except Exception:
            if self.statevector is None:
                self.statevector = Statevector.from_label('0' * self.num_qubits)
            return self.statevector

    def get_qubit_states(self) -> List[Dict[str, Any]]:
        """
        Extract pure quantum state data for each qubit.
        Godot handles visualization (positions, colors).

        Returns:
            List of qubit states with amplitude, phase, probability
        """
        if self.statevector is None:
            self.get_statevector()

        qubit_states = []
        state_data = self.statevector.data

        for i in range(self.num_qubits):
            prob_0, prob_1, amp_0, amp_1 = self._compute_single_qubit_state(i, state_data)

            # Use dominant amplitude
            if prob_0 > prob_1:
                primary_amp = amp_0
                dominant_prob = prob_0
            else:
                primary_amp = amp_1
                dominant_prob = prob_1

            # Extract phase
            phase = float(np.angle(primary_amp))

            qubit_states.append({
                'id': i,
                'amplitude': complex(primary_amp),
                'phase': phase,
                'probability': float(dominant_prob)
            })

        return qubit_states

    def _compute_single_qubit_state(self, qubit_idx: int, state_data: np.ndarray):
        """Compute single-qubit marginal state."""
        prob_0 = prob_1 = 0.0
        amp_0_sum = amp_1_sum = 0.0 + 0.0j

        for i, amplitude in enumerate(state_data):
            bit_value = (i >> qubit_idx) & 1
            prob = np.abs(amplitude) ** 2

            if bit_value == 0:
                prob_0 += prob
                amp_0_sum += amplitude
            else:
                prob_1 += prob
                amp_1_sum += amplitude

        if prob_0 > 1e-10:
            amp_0_sum /= np.sqrt(prob_0)
        if prob_1 > 1e-10:
            amp_1_sum /= np.sqrt(prob_1)

        return prob_0, prob_1, amp_0_sum, amp_1_sum

    def measure_qubit(self, qubit_index: int) -> int:
        """Measure a single qubit and return the result (0 or 1)."""
        if self.statevector is None:
            self.get_statevector()

        # Simple measurement simulation - just return 0 or 1 based on probability
        state_data = self.statevector.data
        prob_0, prob_1, _, _ = self._compute_single_qubit_state(qubit_index, state_data)

        # Return 0 if |0⟩ is more likely, 1 if |1⟩ is more likely
        return 0 if prob_0 > prob_1 else 1

    def get_circuit_depth(self) -> str:
        """Get circuit depth information."""
        return str(self.circuit.depth())

    def get_circuit_diagram(self) -> str:
        """Get ASCII circuit diagram."""
        try:
            return str(self.circuit.draw(output='text', fold=-1))
        except:
            return "Circuit diagram unavailable"

    def get_amplitudes(self) -> List[complex]:
        """Get raw quantum amplitudes for advanced visualization."""
        if self.statevector is None:
            self.get_statevector()
        return [complex(amp) for amp in self.statevector.data]
