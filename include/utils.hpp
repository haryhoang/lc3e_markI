#ifndef UTILS_HPP
#define UTILS_HPP

#include <cstdint>

// Chuyen doi bit tu 0000 0000 0001 1111 -> 1111 1111 1111 1111
inline uint16_t sign_extend(uint16_t x, int bit_count){

    if ((x >> (bit_count -1 )) & 1){
        x |= (0xFFFF << bit_count);
    }
    return x;
}
#endif