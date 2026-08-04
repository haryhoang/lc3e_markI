#include <iostream>
#include <fstream>
#include <cstdint>

uint16_t swap16(uint16_t x) {
    return (x << 8) | (x >> 8);
}

int main() {
    std::ofstream file("loop.obj", std::ios::binary);
    if (!file) {
        std::cerr << "Cannot create file!\n";
        return 1;
    }

    // 1. Ghi địa chỉ khởi đầu của chương trình (Origin Address): 0x3000
    uint16_t origin = swap16(0x3000);
    file.write(reinterpret_cast<char*>(&origin), 2);

    // 2. Định nghĩa các lệnh mã máy của chương trình vòng lặp
    uint16_t instrs[] = {
        swap16(0x1265), // ADD R1, R1, #5  (Gán R1 = 5 đóng vai trò bộ đếm vòng lặp)
        swap16(0x54A0), // AND R2, R2, #0  (Xóa R2 về 0 để lưu kết quả cộng)
        
        // --- Bắt đầu vòng lặp (Địa chỉ 0x3002) ---
        swap16(0x14A1), // ADD R2, R2, #1  (R2 = R2 + 1)
        swap16(0x127F), // ADD R1, R1, #-1 (Giảm bộ đếm R1 đi 1)
        swap16(0x03FD), // BRp -3          (Nếu R1 vẫn > 0, nhảy ngược lại 3 ô nhớ về đầu vòng lặp)
        
        // --- Kết thúc vòng lặp ---
        swap16(0xF025)  // Lệnh HALT dừng chương trình
    };

    for (uint16_t instr : instrs) {
        file.write(reinterpret_cast<char*>(&instr), 2);
    }

    std::cout << "Successfully generated loop.obj!\n";
    return 0;
}