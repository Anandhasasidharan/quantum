"""
E91 Entanglement-Based Quantum Key Distribution
Uses Bell pairs and CHSH inequality violation testing
"""

import numpy as np
from typing import Dict, List, Any, Optional
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from .base import QuantumMissionSimulator


class E91Simulator(QuantumMissionSimulator):
    """E91: Entanglement-based QKD with CHSH inequality testing."""

    def __init__(self, num_qubits: int = 2):
        super().__init__(num_qubits)
        self.alice_bits, self.bob_bits = [], []
        self.alice_angles, self.bob_angles = [], []
        self.correlations = []
        self.chsh_value = 0.0
        self.key_bits = []
        self.eve_detected = False

    def initialize(self, parameters: Dict[str, Any]) -> None:
        """Initialize E91 protocol with Bell pair generation."""
        self.reset()
        self.eve_active = parameters.get('eve_active', False)

        # Create Bell pair (|00⟩ + |11⟩)/√2
        self.engine.circuit.h(0)  # Put qubit 0 in superposition
        self.engine.circuit.cnot(0, 1)  # Entangle with qubit 1

        # Initialize angle choices for CHSH test
        self.alice_angles = [0, np.pi/4, np.pi/2, 3*np.pi/4]  # Alice's measurement angles
        self.bob_angles = [np.pi/8, 3*np.pi/8, 5*np.pi/8, 7*np.pi/8]  # Bob's measurement angles

        self.step_count = 1
        self.mission_state = {
            'step': self.step_count,
            'bell_state': 'entangled',
            'alice_bits': self.alice_bits,
            'bob_bits': self.bob_bits,
            'correlations': self.correlations,
            'chsh_value': self.chsh_value,
            'key_bits': self.key_bits,
            'eve_detected': self.eve_detected,
            'quantum_states': self.engine.get_amplitudes()
        }

    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute E91 measurement and CHSH testing steps."""
        self.eve_active = parameters.get('eve_active', self.eve_active)
        self.step_count += 1

        if self.step_count % 4 == 2:  # Measurement phase
            # Alice and Bob choose random measurement angles
            alice_angle = np.random.choice(self.alice_angles)
            bob_angle = np.random.choice(self.bob_angles)

            # Simulate measurements with entangled outcomes
            circuit = self.engine.circuit.copy()

            # Alice's measurement (rotate basis)
            circuit.ry(2 * alice_angle, 0)
            # Bob's measurement (rotate basis)
            circuit.ry(2 * bob_angle, 1)

            # Measure both qubits
            circuit.measure_all()

            # Run simulation
            result = AerSimulator().run(circuit, shots=1).result()
            bitstring = list(result.get_counts().keys())[0]

            alice_bit = int(bitstring[1])  # Qubit 0 result
            bob_bit = int(bitstring[0])    # Qubit 1 result

            self.alice_bits.append(alice_bit)
            self.bob_bits.append(bob_bit)

            # Calculate correlation for CHSH
            correlation = (-1) ** (alice_bit + bob_bit)  # +1 if same, -1 if different
            self.correlations.append(correlation)

            # Generate key from matching measurement bases
            if abs(alice_angle - bob_angle) < 0.1:  # Similar angles = key bit
                self.key_bits.append(alice_bit)

        elif self.step_count % 8 == 0:  # CHSH evaluation phase
            if len(self.correlations) >= 4:
                # Calculate CHSH value: S = |E(a,b) - E(a,b') + E(a',b) + E(a',b')|
                # For Bell pairs, max violation is 2√2 ≈ 2.83
                recent_corr = self.correlations[-4:]
                self.chsh_value = abs(recent_corr[0] - recent_corr[1] + recent_corr[2] + recent_corr[3])

                # Check for eavesdropping (reduces CHSH violation)
                if self.chsh_value < 2.0:  # Below quantum limit
                    self.eve_detected = True

        # Reset Bell pair for next round
        self.engine.reset(self.num_qubits)
        self.engine.circuit.h(0)
        self.engine.circuit.cnot(0, 1)

        self.mission_state = {
            'step': self.step_count,
            'bell_state': 'entangled',
            'alice_bits': self.alice_bits[-10:],  # Show last 10 bits
            'bob_bits': self.bob_bits[-10:],
            'correlations': self.correlations[-10:],
            'chsh_value': round(self.chsh_value, 3),
            'chsh_violation': self.chsh_value > 2.0,
            'key_bits': self.key_bits[-20:],  # Show last 20 key bits
            'key_length': len(self.key_bits),
            'eve_detected': self.eve_detected,
            'eve_active': self.eve_active,
            'quantum_states': self.engine.get_amplitudes()
        }

        return self.mission_state

    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """Manual Bell state measurement."""
        results = []

        for qubit_id in qubit_indices:
            if qubit_id >= self.num_qubits:
                continue

            # Measure in computational basis
            circuit = self.engine.circuit.copy()
            circuit.measure_all()

            result = AerSimulator().run(circuit, shots=1).result()
            bitstring = list(result.get_counts().keys())[0]
            outcome = int(bitstring[-(qubit_id + 1)])

            results.append({
                'qubit_id': qubit_id,
                'outcome': outcome,
                'basis': 'computational',
                'entangled': True
            })

        return results

    def get_visualization_data(self) -> Dict[str, Any]:
        """Get data for E91 twin drones + CHSH violation visualization."""
        return {
            'mission_type': 'e91',
            'bell_pairs': [
                {'qubit_a': 0, 'qubit_b': 1, 'entangled': True}
            ],
            'chsh_meter': {
                'value': self.chsh_value,
                'violation': self.chsh_value > 2.0,
                'max_classical': 2.0,
                'max_quantum': 2.83
            },
            'twin_drones': {
                'alice_position': [0, 0, 0],
                'bob_position': [10, 0, 0],
                'entanglement_beam': True
            }
        }