"""BB84 Quantum Key Distribution - Simplified for hackathon."""

import numpy as np
from typing import Dict, Any, List, Optional
from qiskit_aer import AerSimulator
from .base import QuantumMissionSimulator


class BB84Simulator(QuantumMissionSimulator):
    """BB84: Quantum key distribution with eavesdropping detection."""

    def __init__(self, num_qubits: int = 12):
        super().__init__(num_qubits)
        self.alice_bits, self.alice_bases, self.bob_bases, self.bob_results = [], [], [], []
        self.eve_active, self.sifted_key, self.error_rate = False, [], 0.0

    def initialize(self, parameters: Dict[str, Any]) -> None:
        """Start BB84 protocol."""
        self.reset()
        self.eve_active = parameters.get('eve_active', False)

        # Generate random bits and bases
        self.alice_bits = [np.random.randint(0, 2) for _ in range(self.num_qubits)]
        self.alice_bases = [np.random.choice(['rectilinear', 'diagonal']) for _ in range(self.num_qubits)]
        self.bob_bases = [np.random.choice(['rectilinear', 'diagonal']) for _ in range(self.num_qubits)]

        # Alice prepares qubits
        for i in range(self.num_qubits):
            if self.alice_bases[i] == 'rectilinear':
                if self.alice_bits[i] == 1:
                    self.engine.circuit.x(i)
            else:  # diagonal
                if self.alice_bits[i] == 0:
                    self.engine.circuit.h(i)
                else:
                    self.engine.circuit.x(i)
                    self.engine.circuit.h(i)

        self.step_count = 1

    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute BB84 steps."""
        # Update Eve status from current parameters
        self.eve_active = parameters.get('eve_active', self.eve_active)
        self.step_count += 1

        if self.step_count == 2:
            # Eve intercepts if active
            if self.eve_active:
                eve_bases = [np.random.choice(['rectilinear', 'diagonal']) for _ in range(self.num_qubits)]
                eve_results = []

                for i in range(self.num_qubits):
                    circuit = self.engine.circuit.copy()
                    if eve_bases[i] == 'diagonal':
                        circuit.h(i)
                    circuit.measure_all()

                    result = AerSimulator().run(circuit, shots=1).result()
                    bitstring = list(result.get_counts().keys())[0]
                    eve_results.append(int(bitstring[-(i + 1)]))

                # Eve resends (introduces errors)
                self.engine.reset(self.num_qubits)
                for i in range(self.num_qubits):
                    if eve_bases[i] == 'rectilinear':
                        if eve_results[i] == 1:
                            self.engine.circuit.x(i)
                    else:
                        if eve_results[i] == 0:
                            self.engine.circuit.h(i)
                        else:
                            self.engine.circuit.x(i)
                            self.engine.circuit.h(i)

            # Bob measures
            self.bob_results = []
            for i in range(self.num_qubits):
                circuit = self.engine.circuit.copy()
                if self.bob_bases[i] == 'diagonal':
                    circuit.h(i)
                circuit.measure_all()

                result = AerSimulator().run(circuit, shots=1).result()
                bitstring = list(result.get_counts().keys())[0]
                self.bob_results.append(int(bitstring[-(i + 1)]))

        elif self.step_count == 3:
            # Sifting
            matching = []
            errors = 0

            for i in range(self.num_qubits):
                if self.alice_bases[i] == self.bob_bases[i]:
                    matching.append(i)
                    self.sifted_key.append(self.bob_results[i])
                    if self.bob_results[i] != self.alice_bits[i]:
                        errors += 1

            self.error_rate = errors / len(matching) if matching else 0.0

            self.mission_state = {
                'alice_bits': self.alice_bits,
                'alice_bases': self.alice_bases,
                'bob_bases': self.bob_bases,
                'bob_results': self.bob_results,
                'eve_active': self.eve_active,
                'sifted_key': self.sifted_key,
                'error_rate': self.error_rate,
                'eve_detected': self.error_rate > 0.11,
                'key_length': len(self.sifted_key),
                'current_step': self.step_count
            }

        return self.mission_state

    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """Manual measurement."""
        basis = basis or 'rectilinear'
        results = []

        for i in qubit_indices:
            if 0 <= i < self.num_qubits:
                circuit = self.engine.circuit.copy()
                if basis == 'diagonal':
                    circuit.h(i)
                circuit.measure_all()

                result = AerSimulator().run(circuit, shots=1).result()
                bitstring = list(result.get_counts().keys())[0]
                results.append({'qubit': i, 'result': int(bitstring[-(i + 1)]), 'basis': basis})

        return results

    def get_mission_info(self) -> Dict[str, Any]:
        """Return mission info."""
        return {
            'mission_name': 'BB84 Protocol',
            'category': 'Quantum Key Distribution',
            'description': 'Secure quantum key with eavesdropping detection',
            'qubits': self.num_qubits
        }

    def reset(self) -> None:
        """Reset protocol."""
        super().reset()
        self.alice_bits, self.alice_bases, self.bob_bases, self.bob_results = [], [], [], []
        self.eve_active, self.sifted_key, self.error_rate = False, [], 0.0
