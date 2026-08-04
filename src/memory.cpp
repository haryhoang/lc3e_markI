#include "memory.hpp"

#include <cstdint>
using namespace std;

Memory::Memory()
{
    for (int i=0; i< 65536; i++)
    {
        ram[i] = 0;
    }
}

// Nap tu ram (Load Word)
uint16_t Memory::read(uint16_t address) 
{
    return ram[address];
}

// Luu tru vao Ram (Store Word)
void Memory::write(uint16_t address, uint16_t value) 
{
    ram[address] = value;
}