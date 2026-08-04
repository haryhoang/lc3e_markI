#include "cpu.hpp"
#include "memory.hpp"
#include "registers.hpp"

#include <iostream>
using namespace std;

int main(int argc, char* argv[]) {
    if (argc < 2) {
        cout << "Usage: lc3 [image_file]\n";
        return 1;
    }

    Memory memory;
    CPU cpu(memory);

    if (!cpu.read_image(argv[1])) { // 
        return 1;
    }

    cout << "--- Starting Emulator ---\n";
    cpu.run();
    cout << "--- Emulator Finished ---\n";
    
    return 0;
}

// copy shift alt a -> comment
/* // New testbench
     cpu.load_instruction(0x3000, 0x126F); // R1 = R1 + 15 (R1 lúc này bằng 15)
    PC = 0x3001 (After fetch)

    // Bước 2: Lưu R1 vào ô nhớ cách vị trí hiện tại một khoảng (ST R1, offset=5) -> Mã máy: 0x3205
    cpu.load_instruction(0x3001, 0x3205);
    PC = 0x3002 (After fetch)
    // Giải mã: 0011 (ST) 001 (sR1) 000000101 (offset 5-bit -> thực tế ô nhớ mục tiêu là 0x3002+ 5 = 0x3007)


    // Bước 3: Xóa thanh ghi R2 về 0 (AND R2, R2, #0) -> Mã máy: 0x54A0
    cpu.load_instruction(0x3002, 0x54A0);
    PC = 0x3003 (After fetch)

    // Bước 4: Đọc lại giá trị từ ô nhớ đó vào R2 (LD R2, offset=4) -> Mã máy: 0x2404
     cpu.load_instruction(0x3003, 0x2403);
     PC = 0x3004
    // Giải mã: 0010 (LD) 010 (R2) 000000100 (offset 4)
    // Ô nhớ mục tiêu: 0x3004 + 4 = 0x3008. 
    // Khoan đã! Ở bước 2 ta ghi vào 0x3007. Vậy ở truoc bước 4, PC đang ở 0x3003, sau khi Fetch PC = 0x3004.
    // Để trỏ đúng vào 0x3007, offset phải là: 0x3007 - 0x3004 = 3, nghia la offset = 3 (nhị phân là 000000011) -> Mã máy: 0x2403


    // Lệnh HALT dừng chương trình
    cpu.load_instruction(0x3004, 0xF025); 
    PC = 0x005*/
