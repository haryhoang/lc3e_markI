# lc3e markI: Enhanced LC-3 Processor Design & Simulator

## 📌 Project Overview
**lc3e markI** is a high-performance C/C++ behavioral simulator and architectural blueprint for an enhanced **LC-3 (Little Computer 3)** 16-bit processor. While the baseline LC-3 ISA supports 15 standard opcodes, this design expands the instruction set to **20+ instructions** using sub-opcode decoding (funct fields), laying the structural foundation for upcoming Verilog RTL synthesis and FPGA deployment.

---

## 🚀 Key Features
- **Architecture:** 16-bit Von Neumann Architecture.
- **Register File:** 8 General-Purpose Registers ($R_0$ - $R_7$) with hardware-enforced $R_0 = 0$ constant guard.
- **Extended ISA:** Expanded from 15 to 20+ instructions via **Opcode Extension** (Sub-opcode decoding).
- **Execution Model:** Full Fetch-Decode-Execute instruction cycle with modular Control Unit and Datapath separation.
- **Language & Stack:** C++17 (Object-Oriented Hardware Modeling).

---

## 🛠 ISA Extensions Summary

Using the vacant bits in standard instruction formats (e.g., Opcode `1001`), additional arithmetic and bitwise capabilities have been integrated:

| Instruction | Opcode / Sub-Opcode | Description |
| :--- | :--- | :--- |
| `SUB` | `1101` | Subtracts source operand from register (`DR = SR1 - SR2 / imm5`). |
| `NEG` | `1001` (Sub: `0x1`) | Two's complement negation (`DR = -SR`). |
| `SLL` | `1001` (Sub: `0x1`) | Shift Left Logical by $N$ bits (`DR = SR << amount4`). |
| `SRL` | `1001` (Sub: `0x2`) | Shift Right Logical by $N$ bits (`DR = SR >> amount4`). |
| `SRA` | `1001` (Sub: `0x3`) | Shift Right Arithmetic (preserves sign bit). |
| `NOT` | `1001` (Default) | Bitwise complement (`DR = ~SR`). |

---

## 🏗 Microarchitecture & Software Design

The project is structured around hardware-equivalent software blocks:

1. **ALU (Arithmetic Logic Unit):** Handles arithmetic, logic, bit-shifting, and flag updates ($N, Z, P$).
2. **Register File:** Fast-access storage with zero-register safety logic (`R0 Guard`).
3. **Control Unit (FSM):** Decodes primary opcodes and sub-opcodes to generate control signals.
4. **Memory Interface:** Abstracts instruction fetching and data read/write cycles.

---

## 💻 Building & Running

### Prerequisites
- C++17 compliant compiler (`g++` or `clang++`)
- `make` or CMake (optional)

### Compilation & Execution
```bash
# Clone the repository
git clone [https://github.com/your-username/lc3e-markI.git](https://github.com/your-username/lc3e-markI.git)
cd lc3e-markI

# Compile the simulator
g++ -std=c++17 -O2 main.cpp cpu.cpp memory.cpp -o lc3e_sim

# Run the simulator with a machine code binary
./lc3e_sim program.bin
