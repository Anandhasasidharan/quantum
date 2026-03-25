"""
Shor's Algorithm for Integer Factorization
Period-finding using Quantum Fourier Transform
"""

import numpy as np
import math
from typing import Dict, List, Any, Optional
from qiskit import QuantumCircuit
from qiskit_aer import AerSimulator
from .base import QuantumMissionSimulator


class ShorSimulator(QuantumMissionSimulator):
    """Shor's algorithm: Quantum period-finding for factorization."""

    def __init__(self, num_qubits: int = 6):
        super().__init__(num_qubits)
        self.N = 15  # Number to factor (15 = 3 × 5)
        self.a = 7   # Random base (coprime to N)
        self.period = None
        self.factors = []
        self.qft_results = []
        self.iteration = 0
        self.period_candidates = []

    def initialize(self, parameters: Dict[str, Any]) -> None:
        """Initialize Shor's algorithm."""
        self.reset()
        self.N = parameters.get('number_to_factor', 15)
        self.a = parameters.get('base', 7)
        self.iteration = 0

        # For N=15, a=7: period is 4 since 7^4 ≡ 1 (mod 15)
        # Expected sequence: 7^0=1, 7^1=7, 7^2=4, 7^3=13, 7^4=1 (mod 15)

        # Initialize superposition over first register (period-finding qubits)
        for i in range(self.num_qubits // 2):
            self.engine.circuit.h(i)

        self.step_count = 1
        self.mission_state = {
            'step': self.step_count,
            'algorithm': 'shor',
            'N': self.N,
            'base_a': self.a,
            'period': self.period,
            'factors': self.factors,
            'qft_results': self.qft_results,
            'iteration': self.iteration,
            'period_candidates': self.period_candidates,
            'quantum_states': self.engine.get_amplitudes()
        }

    def step(self, parameters: Dict[str, Any]) -> Dict[str, Any]:
        """Execute Shor's algorithm steps."""
        self.step_count += 1
        self.iteration += 1

        # Simulate modular exponentiation a^x mod N
        # For educational purposes, we'll simulate the period-finding
        if self.step_count == 2:
            # Apply controlled modular exponentiation
            # This creates entanglement between input and output registers
            self.add_modular_exponentiation()

        elif self.step_count == 3:
            # Apply Quantum Fourier Transform to extract period
            self.apply_qft()

        elif self.step_count >= 4:
            # Measure and process results
            self.measure_and_find_period()

            # Classical post-processing to find factors
            if self.period and self.period > 1:
                self.classical_factoring()

            # Reset for next iteration
            if self.iteration % 4 == 0:
                self.reset_for_next_iteration()

        self.mission_state = {
            'step': self.step_count,
            'algorithm': 'shor',
            'N': self.N,
            'base_a': self.a,
            'period': self.period,
            'factors': self.factors,
            'qft_results': self.qft_results[-10:],  # Last 10 measurements
            'iteration': self.iteration,
            'period_candidates': self.period_candidates[-5:],  # Last 5 candidates
            'success': len(self.factors) > 0,
            'quantum_advantage': True if self.period else False,
            'quantum_states': self.engine.get_amplitudes()
        }

        return self.mission_state

    def add_modular_exponentiation(self):
        """Simulate controlled modular exponentiation a^x mod N."""
        # For educational purposes, simulate the effect of |x⟩|0⟩ → |x⟩|a^x mod N⟩
        # In a real implementation, this would be a complex quantum circuit

        # Create entanglement pattern that encodes the period
        # This is a simplified version for visualization
        for i in range(self.num_qubits // 2):
            for j in range(self.num_qubits // 2, self.num_qubits):
                if (i + j) % 2 == 0:  # Simulate period structure
                    self.engine.circuit.cx(i, j)

    def apply_qft(self):
        """Apply Quantum Fourier Transform to extract periodicity."""
        n_qubits = self.num_qubits // 2

        # QFT implementation
        for i in range(n_qubits):
            # Hadamard gate
            self.engine.circuit.h(i)

            # Controlled phase gates
            for j in range(i + 1, n_qubits):
                angle = 2 * np.pi / (2 ** (j - i + 1))
                self.engine.circuit.cp(angle, j, i)

        # Swap qubits to reverse order
        for i in range(n_qubits // 2):
            self.engine.circuit.swap(i, n_qubits - 1 - i)

    def measure_and_find_period(self):
        """Measure QFT result and extract period information."""
        # Measure the first register (QFT output)
        circuit = self.engine.circuit.copy()
        circuit.measure_all()

        result = AerSimulator().run(circuit, shots=1).result()
        bitstring = list(result.get_counts().keys())[0]

        # Extract measurement from first register
        n_qubits = self.num_qubits // 2
        measured_value = int(bitstring[-n_qubits:], 2)
        self.qft_results.append(measured_value)

        # Convert measurement to period using continued fractions
        if measured_value > 0:
            # Simplified period extraction
            fraction = measured_value / (2 ** n_qubits)
            # For N=15, a=7, the period is 4
            estimated_period = round(1 / fraction) if fraction > 0 else None

            if estimated_period and 1 < estimated_period <= self.N:
                self.period_candidates.append(estimated_period)

                # Check if this is the correct period
                if pow(self.a, estimated_period, self.N) == 1:
                    self.period = estimated_period

    def classical_factoring(self):
        """Use found period to factor N classically."""
        if not self.period or self.period % 2 != 0:
            return

        # Compute gcd(a^(r/2) ± 1, N)
        half_period = self.period // 2
        base_power = pow(self.a, half_period, self.N)

        factor1 = math.gcd(base_power - 1, self.N)
        factor2 = math.gcd(base_power + 1, self.N)

        # Check if we found non-trivial factors
        if 1 < factor1 < self.N and self.N % factor1 == 0:
            self.factors = [factor1, self.N // factor1]
        elif 1 < factor2 < self.N and self.N % factor2 == 0:
            self.factors = [factor2, self.N // factor2]

    def reset_for_next_iteration(self):
        """Reset quantum state for next period-finding attempt."""
        self.engine.reset(self.num_qubits)
        for i in range(self.num_qubits // 2):
            self.engine.circuit.h(i)

    def measure(self, qubit_indices: List[int], basis: Optional[str] = None) -> List[Dict[str, Any]]:
        """Manual measurement of Shor's algorithm state."""
        results = []

        for qubit_id in qubit_indices:
            if qubit_id >= self.num_qubits:
                continue

            circuit = self.engine.circuit.copy()
            circuit.measure_all()

            result = AerSimulator().run(circuit, shots=1).result()
            bitstring = list(result.get_counts().keys())[0]
            outcome = int(bitstring[-(qubit_id + 1)])

            results.append({
                'qubit_id': qubit_id,
                'outcome': outcome,
                'register': 'input' if qubit_id < self.num_qubits // 2 else 'output',
                'qft_applied': self.step_count >= 3
            })

        return results

    def get_visualization_data(self) -> Dict[str, Any]:
        """Get data for Shor's period landscape + QFT portal visualization."""
        return {
            'mission_type': 'shor',
            'period_landscape': {
                'N': self.N,
                'base_a': self.a,
                'period': self.period,
                'candidates': self.period_candidates,
                'height_map': self.generate_period_heights()
            },
            'qft_portal': {
                'active': self.step_count >= 3,
                'frequency_peaks': self.qft_results,
                'quantum_interference': True
            },
            'factor_peaks': {
                'factors': self.factors,
                'success': len(self.factors) > 0,
                'verification': self.verify_factorization()
            }
        }

    def generate_period_heights(self) -> List[float]:
        """Generate height map for period visualization."""
        heights = []
        for x in range(16):  # Show period structure
            height = abs(pow(self.a, x, self.N) - 1) / self.N
            heights.append(height)
        return heights

    def verify_factorization(self) -> bool:
        """Verify that found factors are correct."""
        if len(self.factors) == 2:
            return self.factors[0] * self.factors[1] == self.N
        return False