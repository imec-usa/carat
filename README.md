# 4×4 MAC Array with Output Stationary Dataflow

A synthesizable gate-level Verilog implementation of a 4×4 MAC (Multiply-Accumulate) array with output stationary dataflow for high-performance matrix multiplication.

## Overview

This design implements a systolic array architecture where:
- **16-bit integer inputs** flow through the array
- **32-bit accumulated outputs** are stored locally in each PE
- **Output stationary dataflow** keeps partial sums in place
- **High-performance arithmetic** uses optimized gate-level designs

## Architecture

### Processing Element (PE)
Each PE performs: `accumulator = accumulator + (A × B)`

- 16×16 bit multiplier using Wallace/Dadda tree
- 32-bit carry-lookahead adder
- Local accumulator register
- Systolic data passthrough for A (horizontal) and B (vertical)

### Array Structure
```
    B0   B1   B2   B3
    ↓    ↓    ↓    ↓
A0→[PE]→[PE]→[PE]→[PE]
A1→[PE]→[PE]→[PE]→[PE]
A2→[PE]→[PE]→[PE]→[PE]
A3→[PE]→[PE]→[PE]→[PE]
```

Data flows:
- **A matrix**: Horizontally (left to right)
- **B matrix**: Vertically (top to bottom)
- **Results**: Stored locally in each PE

## File Structure

### RTL Design Files
```
csa_32bit.v          - 32-bit Carry-Save Adder (3:2 compressor)
adder_32bit.v        - 32-bit Carry-Lookahead Adder
multiplier_16bit.v   - 16×16 bit Wallace tree multiplier
pe.v                 - Processing Element (MAC unit)
mac_array_4x4.v      - Top-level 4×4 systolic array
```

### Testbench Files
```
tb_adder_32bit.v     - Testbench for 32-bit adder
tb_multiplier_16bit.v - Testbench for 16-bit multiplier
tb_pe.v              - Testbench for MAC PE
tb_mac_array_4x4.v   - Testbench for complete array
```

### Build Files
```
Makefile             - Automated build and test system
README.md            - This file
```

## Building and Testing

### Prerequisites
- Icarus Verilog (iverilog) - for simulation
- GTKWave (optional) - for waveform viewing

Install on Ubuntu/Debian:
```bash
sudo apt-get install iverilog gtkwave
```

### Quick Start

Run all tests:
```bash
make all
```

Run individual component tests:
```bash
make test_adder    # Test 32-bit adder only
make test_mult     # Test 16-bit multiplier only
make test_pe       # Test MAC PE only
make test_array    # Test complete 4×4 array only
```

### Manual Compilation

If you prefer manual compilation:

```bash
# Test adder
iverilog -o adder_sim csa_32bit.v adder_32bit.v tb_adder_32bit.v
./adder_sim

# Test multiplier
iverilog -o mult_sim csa_32bit.v adder_32bit.v multiplier_16bit.v tb_multiplier_16bit.v
./mult_sim

# Test PE
iverilog -o pe_sim csa_32bit.v adder_32bit.v multiplier_16bit.v pe.v tb_pe.v
./pe_sim

# Test complete array
iverilog -o array_sim csa_32bit.v adder_32bit.v multiplier_16bit.v pe.v mac_array_4x4.v tb_mac_array_4x4.v
./array_sim
```

### Viewing Waveforms

After running tests, view the generated waveforms:
```bash
make wave_adder    # View adder waveforms
make wave_mult     # View multiplier waveforms
make wave_pe       # View PE waveforms
make wave_array    # View array waveforms
```

Or manually:
```bash
gtkwave adder_32bit.vcd &
gtkwave multiplier_16bit.vcd &
gtkwave pe.vcd &
gtkwave mac_array_4x4.vcd &
```

## Test Coverage

### Adder Tests (20+ tests)
- Zero handling
- Carry propagation
- Overflow conditions
- Random patterns
- Maximum values

### Multiplier Tests (50+ tests)
- Zero and one multiplication
- Powers of 2
- Maximum 16-bit values
- Bit pattern tests
- Random comprehensive tests

### PE/MAC Tests (25+ tests)
- Basic MAC operations
- Accumulation
- Load/reset operations
- Enable control
- Passthrough verification
- Dot product computation
- Large accumulations

### Array Tests
- Full 4×4 matrix multiplication
- Systolic data flow
- Output stationary verification
- Accumulation across multiple operations

## Design Features

### High-Performance Multiplier
- Wallace/Dadda tree reduction
- Parallel partial product generation
- Carry-save adders for compression
- Final carry-propagate adder
- **Optimized for speed**

### High-Performance Adder
- Hierarchical carry-lookahead design
- 4-bit CLA blocks
- Block-level carry computation
- **Low latency addition**

### Synthesizable Design
- Pure gate-level implementation
- No behavioral constructs in critical path
- Standard cell compatible
- Technology independent

## Performance Characteristics

### Latency
- **Multiplier**: 2-3 gate delays (combinational)
- **Adder**: 1-2 gate delays (combinational)
- **PE MAC**: 1 cycle (pipelined)
- **Array throughput**: 1 result per cycle (after initial fill)

### Systolic Array Timing
For 4×4 array:
- **Fill time**: 7 cycles (diagonal wavefront)
- **Computation cycles**: 4 cycles (for K=4 inner dimension)
- **Total latency**: ~11 cycles
- **Throughput**: 16 MACs per cycle when full

## Usage Example

### Matrix Multiplication

To multiply two 4×4 matrices:

```verilog
// Matrix A (row-wise)
A = [1  2  3  4 ]
    [5  6  7  8 ]
    [9  10 11 12]
    [13 14 15 16]

// Matrix B (column-wise)
B = [2 0 1 0]
    [0 2 0 1]
    [1 0 2 0]
    [0 1 0 2]

// Result C = A × B
C = [7  8  9  10]
    [19 24 29 34]
    [31 40 49 58]
    [43 56 69 82]
```

The testbench demonstrates this computation with proper data scheduling.

## Customization

### Changing Array Size
To create different array sizes (e.g., 8×8):
1. Modify `mac_array_4x4.v` parameter declarations
2. Update generate loops for row/col dimensions
3. Adjust testbench data feeding patterns

### Changing Data Width
To use different bit widths:
1. Modify PE input/output widths
2. Update multiplier for NxN bit multiplication
3. Adjust accumulator width (typically 2×N bits)
4. Update adder width accordingly

### Adding Features
Consider adding:
- Configurable accumulator reset
- Overflow detection/saturation
- Signed arithmetic support
- Pipeline registers for higher frequency

## Known Limitations

- Fixed-point integer only (no floating-point)
- No overflow protection (wraps around)
- Unsigned arithmetic only
- Fixed 4×4 array size

## Future Enhancements

- [ ] Parameterizable array dimensions
- [ ] Signed/unsigned mode selection
- [ ] Saturation arithmetic
- [ ] Configurable data widths
- [ ] AXI-Stream interfaces
- [ ] Power gating support

## References

- Wallace Tree Multiplier: C. S. Wallace, "A Suggestion for a Fast Multiplier", 1964
- Carry-Lookahead Adder: Weinberger & Smith, "A Logic for High-Speed Addition", 1958
- Systolic Arrays: H. T. Kung, "Why Systolic Architectures?", 1982

## License

This design is provided for educational and research purposes.

## Contact

For questions or issues, please check the documentation or open an issue in the repository.
