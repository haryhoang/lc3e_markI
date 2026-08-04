#ifndef MEMORY_HPP
#define MEMORY_HPP

#include <cstdint>

class Memory {
private:
    uint16_t ram[65536]; // ram 64KB

public:
    Memory(); 
    void write(uint16_t address, uint16_t value); 
    uint16_t read(uint16_t address);

};
#endif