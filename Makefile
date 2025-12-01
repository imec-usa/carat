# Makefile for 4x4 MAC Array Testbenches
# Supports Icarus Verilog (iverilog) simulation

# Compiler
VERILOG = iverilog
SIMULATOR = vvp
WAVEVIEWER = gtkwave

# Compiler flags
VFLAGS = -g2012 -Wall

# Source files
GATE_SOURCES = csa_32bit.v adder_32bit.v multiplier_16bit.v
PE_SOURCE = pe.v
ARRAY_SOURCE = mac_array_4x4.v

# Testbench files
TB_ADDER = tb_adder_32bit.v
TB_MULT = tb_multiplier_16bit.v
TB_PE = tb_pe.v
TB_ARRAY = tb_mac_array_4x4.v

# Output executables
EXEC_ADDER = adder_sim
EXEC_MULT = mult_sim
EXEC_PE = pe_sim
EXEC_ARRAY = array_sim

# VCD output files
VCD_ADDER = adder_32bit.vcd
VCD_MULT = multiplier_16bit.vcd
VCD_PE = pe.vcd
VCD_ARRAY = mac_array_4x4.vcd

# Default target - run all tests
.PHONY: all
all: test_adder test_mult test_pe test_array

# Individual test targets
.PHONY: test_adder
test_adder: $(EXEC_ADDER)
	@echo "==================================================="
	@echo "Running 32-bit Adder Tests..."
	@echo "==================================================="
	./$(EXEC_ADDER)
	@echo ""

.PHONY: test_mult
test_mult: $(EXEC_MULT)
	@echo "==================================================="
	@echo "Running 16-bit Multiplier Tests..."
	@echo "==================================================="
	./$(EXEC_MULT)
	@echo ""

.PHONY: test_pe
test_pe: $(EXEC_PE)
	@echo "==================================================="
	@echo "Running MAC PE Tests..."
	@echo "==================================================="
	./$(EXEC_PE)
	@echo ""

.PHONY: test_array
test_array: $(EXEC_ARRAY)
	@echo "==================================================="
	@echo "Running 4x4 MAC Array Tests..."
	@echo "==================================================="
	./$(EXEC_ARRAY)
	@echo ""

# Build executables
$(EXEC_ADDER): $(GATE_SOURCES) $(TB_ADDER)
	@echo "Building adder testbench..."
	$(VERILOG) $(VFLAGS) -o $(EXEC_ADDER) $(GATE_SOURCES) $(TB_ADDER)

$(EXEC_MULT): $(GATE_SOURCES) $(TB_MULT)
	@echo "Building multiplier testbench..."
	$(VERILOG) $(VFLAGS) -o $(EXEC_MULT) $(GATE_SOURCES) $(TB_MULT)

$(EXEC_PE): $(GATE_SOURCES) $(PE_SOURCE) $(TB_PE)
	@echo "Building PE testbench..."
	$(VERILOG) $(VFLAGS) -o $(EXEC_PE) $(GATE_SOURCES) $(PE_SOURCE) $(TB_PE)

$(EXEC_ARRAY): $(GATE_SOURCES) $(PE_SOURCE) $(ARRAY_SOURCE) $(TB_ARRAY)
	@echo "Building array testbench..."
	$(VERILOG) $(VFLAGS) -o $(EXEC_ARRAY) $(GATE_SOURCES) $(PE_SOURCE) $(ARRAY_SOURCE) $(TB_ARRAY)

# View waveforms
.PHONY: wave_adder
wave_adder: $(VCD_ADDER)
	$(WAVEVIEWER) $(VCD_ADDER) &

.PHONY: wave_mult
wave_mult: $(VCD_MULT)
	$(WAVEVIEWER) $(VCD_MULT) &

.PHONY: wave_pe
wave_pe: $(VCD_PE)
	$(WAVEVIEWER) $(VCD_PE) &

.PHONY: wave_array
wave_array: $(VCD_ARRAY)
	$(WAVEVIEWER) $(VCD_ARRAY) &

# Clean targets
.PHONY: clean
clean:
	@echo "Cleaning up..."
	rm -f $(EXEC_ADDER) $(EXEC_MULT) $(EXEC_PE) $(EXEC_ARRAY)
	rm -f *.vcd
	rm -f *.vvp
	@echo "Clean complete."

# Help target
.PHONY: help
help:
	@echo "Makefile for 4x4 MAC Array Simulation"
	@echo ""
	@echo "Available targets:"
	@echo "  all          - Run all tests (default)"
	@echo "  test_adder   - Run 32-bit adder tests"
	@echo "  test_mult    - Run 16-bit multiplier tests"
	@echo "  test_pe      - Run MAC PE tests"
	@echo "  test_array   - Run 4x4 MAC array tests"
	@echo ""
	@echo "  wave_adder   - View adder waveforms"
	@echo "  wave_mult    - View multiplier waveforms"
	@echo "  wave_pe      - View PE waveforms"
	@echo "  wave_array   - View array waveforms"
	@echo ""
	@echo "  clean        - Remove all generated files"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Example usage:"
	@echo "  make test_adder    # Run only adder tests"
	@echo "  make all           # Run all tests"
	@echo "  make clean         # Clean all generated files"
