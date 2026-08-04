#ifndef CPU_HPP
#define CPU_HPP

#include "memory.hpp"
#include "registers.hpp"
#include <string>
using namespace std;

class CPU
{
private:
    uint16_t reg[RCount]; // Cpu chua cac thanh ghi

    Memory& mem; // Cpu tham chieu den memory (bus)
    bool running = true;

    void update_flags(Register r);
    void execute(uint16_t intstr);

public:
    CPU (Memory & mem );
    void run();
    void load_instruction(uint16_t address, uint16_t intstr);
    bool read_image(const string& image_path);
};
#endif 