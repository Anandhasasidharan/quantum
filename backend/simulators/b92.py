"""
B92 Quantum Key Distribution Protocol
Simple 2-state protocol using non-orthogonal quantum states
"""

import numpy as np
from typing import Dict, List, Any, Optional
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from .base import QuantumMissionSimulator


class B92Simulator(QuantumMissionSimulator):
    """B92: Simple 2-state QKD protocol with non-orthogonal states."""

    def __init__(self, num_qubits: int = 1):
        super().__init__(num_qubits)
        self.alice_bits = []
        self.alice_states = []  # |0⟩ or |+⟩
        self.bob_measurements = []
        self.bob_bases = []  # 'rectilinear' or 'diagonal'
        self.sifted_key = []
        self.error_rate = 0.0
        self.photon_count = 0

    def initialize(self, parameters: Dict[str, Any]) -> None:
        """Initialize B92 protocol."""
        self.reset()
        self.eve_active = parameters.get('eve_active', False)
        self.photon_count = 0

        self.step_count = 1
        self.mission_state = {
            'step': self.step_count,
            'protocol': 'b92',
            'alice_bits': self.alice_bits,
            'alice_states': self.alice_states,
            'bob_measurements': self.bob_measurements,
            'bob_bases': self.bob_bases,
            'sifted_key': self.sifted_key,
            'error_rate': self.error_rate,
            'photon_count': self.photon_count,
            'eve_active': self.eve_active,
            'quantum_states': self.engine.get_amplitudes()
        }

    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute B92 protocol steps."""
        self.eve_active = parameters.get('eve_active', self.eve_active)
        self.step_count += 1
        self.photon_count += 1

        # Alice generates random bit and encodes it
        alice_bit = np.random.randint(0, 2)
        self.alice_bits.append(alice_bit)

        # Reset circuit for new photon
        self.engine.reset(self.num_qubits)

        if alice_bit == 0:
            # Send |0⟩ state (do nothing, already in |0⟩)
            self.alice_states.append('|0⟩')
        else:
            # Send |+⟩ state (|0⟩ + |1⟩)/√2
            self.engine.circuit.h(0)
            self.alice_states.append('|+⟩')

        # Eve intercepts if active (introduces errors)
        if self.eve_active:
            # Eve randomly measures in rectilinear or diagonal basis
            eve_basis = np.random.choice(['rectilinear', 'diagonal'])
            circuit = self.engine.circuit.copy()

            if eve_basis == 'diagonal':
                circuit.h(0)  # Rotate to diagonal basis

            circuit.measure_all()
            result = AerSimulator().run(circuit, shots=1).result()
            bitstring = list(result.get_counts().keys())[0]
            eve_result = int(bitstring[0])

            # Eve resends the state (introduces errors)
            self.engine.reset(self.num_qubits)
            if eve_basis == 'rectilinear':
                if eve_result == 1:
                    self.engine.circuit.x(0)
            else:  # diagonal
                if eve_result == 0:
                    self.engine.circuit.h(0)
                else:
                    self.engine.circuit.x(0)
                    self.engine.circuit.h(0)

        # Bob randomly chooses measurement basis
        bob_basis = np.random.choice(['rectilinear', 'diagonal'])
        self.bob_bases.append(bob_basis)

        # Bob measures
        circuit = self.engine.circuit.copy()
        if bob_basis == 'diagonal':
            circuit.h(0)  # Rotate to diagonal basis

        circuit.measure_all()
        result = AerSimulator().run(circuit, shots=1).result()
        bitstring = list(result.get_counts().keys())[0]
        bob_measurement = int(bitstring[0])
        self.bob_measurements.append(bob_measurement)

        # B92 sifting: Keep only successful detections
        # Alice sends |0⟩ → Bob should get 0 in rectilinear basis
        # Alice sends |+⟩ → Bob should get 0 in diagonal basis
        if (alice_bit == 0 and bob_basis == 'rectilinear' and bob_measurement == 0) or \
           (alice_bit == 1 and bob_basis == 'diagonal' and bob_measurement == 0):
            # Successful detection - add to sifted key
            self.sifted_key.append(alice_bit)

        # Calculate error rate periodically
        if len(self.sifted_key) >= 10:
            # In B92, we can estimate error rate from detection efficiency
            detection_rate = len(self.sifted_key) / self.photon_count
            expected_rate = 0.25  # Theoretical for B92 without eavesdropping
            self.error_rate = abs(detection_rate - expected_rate) / expected_rate

        self.mission_state = {
            'step': self.step_count,
            'protocol': 'b92',
            'alice_bits': self.alice_bits[-20:],  # Last 20 bits
            'alice_states': self.alice_states[-20:],
            'bob_measurements': self.bob_measurements[-20:],
            'bob_bases': self.bob_bases[-20:],
            'sifted_key': self.sifted_key[-10:],  # Last 10 key bits
            'key_length': len(self.sifted_key),
            'error_rate': round(self.error_rate, 3),
            'detection_rate': round(len(self.sifted_key) / max(self.photon_count, 1), 3),
            'photon_count': self.photon_count,
            'eve_active': self.eve_active,
            'eve_detected': self.error_rate > 0.2,
            'quantum_states': self.engine.get_amplitudes()
        }

        return self.mission_state

    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """Manual measurement of B92 photon."""
        results = []
        basis = basis or 'rectilinear'

        for qubit_id in qubit_indices:
            if qubit_id >= self.num_qubits:
                continue

            circuit = self.engine.circuit.copy()
            if basis == 'diagonal':
                circuit.h(qubit_id)

            circuit.measure_all()
            result = AerSimulator().run(circuit, shots=1).result()
            bitstring = list(result.get_counts().keys())[0]
            outcome = int(bitstring[-(qubit_id + 1)])

            results.append({
                'qubit_id': qubit_id,
                'outcome': outcome,
                'basis': basis,
                'photon_detected': outcome == 0  # B92 detection criterion
            })

        return results

    def get_visualization_data(self) -> Dict[str, Any]:
        """Get data for B92 simple photon flight visualization."""
        current_state = self.alice_states[-1] if self.alice_states else '|0⟩'

        return {
            'mission_type': 'b92',
            'photon_stream': {
                'current_state': current_state,
                'polarization': 'linear' if current_state == '|0⟩' else 'diagonal',
                'detection_rate': len(self.sifted_key) / max(self.photon_count, 1)
            },
            'simple_flight': {
                'alice_to_bob': True,
                'photon_color': 'blue' if current_state == '|0⟩' else 'orange',
                'trajectory': 'straight_line'
            }
        }