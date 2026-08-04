
#ifndef REGISTERS_HPP
#define REGISTERS_HPP

// library
#include <cstdint>

enum Register {
    R0 =0, R1, R2, R3, R4, R5, R6, R7,
    RPC, // Thanh ghi PC (Progam counter)
    RFlag, // Thanh ghi Dieu kien (Pos, Zero, Neg)
    RCount // Tong so luong thanh ghi (10)
};

enum Condition_Register {
    RPos = 1 << 0,
    RZer = 1 << 1,
    RNeg = 1 << 2, 
};
#endif