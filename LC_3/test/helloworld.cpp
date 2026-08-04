#include <iostream>
#include <vector>
#include <fstream>
#include <cstdint>

uint16_t swap16(uint16_t x) {
    return (x << 8) | (x >> 8);
}

int main() {
    std::ofstream file("hello.obj", std::ios::binary);
    if (!file) return 1;

    // 1. Khởi đầu tại địa chỉ 0x3000
    uint16_t origin = swap16(0x3000);
    file.write(reinterpret_cast<char*>(&origin), 2);

    // 2. Các lệnh mã máy
    std::vector<uint16_t> program = {
        swap16(0xE002), // LEA R0, 2 -> Lấy địa chỉ chuỗi ký tự (ở ô nhớ 0x3003) bỏ vào R0
        swap16(0xF022), // TRAP x22 -> Gọi PUTS để in chuỗi tại địa chỉ trong R0 ra màn hình
        swap16(0xF025), // TRAP x25 -> Gọi HALT để dừng chương trình
    };

    // 3. Chuỗi ký tự "Hello, World!\n" đổi sang mã ASCII
    std::string message = "Hello, World!\n";
    for (char c : message) {
        program.push_back(swap16(static_cast<uint16_t>(c)));
    }
    program.push_back(0x0000); // Ký tự Null kết thúc chuỗi

    for (uint16_t word : program) {
        file.write(reinterpret_cast<char*>(&word), 2);
    }

    std::cout << "Successfully generated hello.obj!\n";
    return 0;
}