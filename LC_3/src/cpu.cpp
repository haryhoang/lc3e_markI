#include "cpu.hpp"
#include "memory.hpp"
#include "registers.hpp"
#include "utils.hpp"


#include <iostream>
#include <fstream>

using namespace std;

CPU::CPU(Memory& mem) : mem(mem), running(true)// Khoi tao gia tri/ thuoc tinh cho cpu
{
    for (int i=0; i< RCount; i++){
        reg[i] = 0;
    }
    reg[RPC] = 0x3000; // Dia chi bat dau mac dinh cho LC3
    reg[R0] = 0; // LC3e_MarkI: R0 = $Zero
}

// Cap nhat thanh ghi co (Register Flag)
void CPU::update_flags(Register rd){
    if (rd == R0){ // Dam bao R0 = 0
        reg[R0] = 0;
        reg[RFlag] = RZer;
        return ;
    }
    if (reg[rd] == 0){
        reg[RFlag] = RZer;
    }
    else if (reg[rd] >> 15){ // mean 1 -> negative, 0 -> positive
        reg[RFlag] = RNeg;
    }
    else {
        reg[RFlag] = RPos;
    }
}
void CPU::run(){
    while(running)
    {
        // fetch
        uint16_t intstr = mem.read(reg[RPC]); // Load word address (Ram) -> intstr
        reg[RPC]++; // Thay doi dia chi PC ->  PC + 1

        // decode & execute
        execute(intstr); 
    }
}

void CPU::load_instruction(uint16_t address, uint16_t intstr)
{
    mem.write(address, intstr); // Store word (Lưu instruction vào Ram) ram[address] = value
}

void CPU::execute (uint16_t intstr) // Decode and Execute
{
    uint16_t op = intstr >> 12; // Decode Opcode [12, 15]

    switch(op) // Kich hoat ma Opcode
    {
        case (0x01) : { // 0x01 =0000 0000 0000 0001: (Add) Command
            uint16_t rd = (intstr >> 9) & 0x7; // Thanh ghi dich , bit [9, 11]
            uint16_t rs = (intstr >> 6) & 0x7; // Thanh ghi nguon s1, bit [6, 8]

            uint16_t imm_flag = (intstr >> 5) & 0x1; // Thanh ghi kiem tra imm_flag, bit[5]
            // imm_flag == 0 -> bit [0,2] : rt (register s2), imm_flag == 1 -> bit [0, 4] : const (hang so)

            if (imm_flag) { // immflag == 1 -> imm5 = const
                uint16_t imm5 = sign_extend(intstr & 0x1F, 5); // Chuyen doi tu hang soo 5 bit -> hang soo 16 bit (and negative number)
                reg[rd] = reg[rs] + imm5;  
            } else { // register s2
                uint16_t rt = intstr & 0x7; // register source 2 has the length 3 bit
                reg[rd] = reg[rs] + reg[rt];
            }
            update_flags(static_cast<Register>(rd));
            cout << "Executed ADD: R" << rd << " = " << reg[rd] << endl;
            break;
        }

        case 0xD : { // lc3e_MarkI : Sub : Opcode : 1101
            // format: [Opcode 4 bit][rd 3 bit][rs 3 bit][imm_flag 1 bit][imm5 5 bit]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t rs = (intstr >> 6) & 0x7;

            uint16_t imm_flag = (intstr >> 5) & 0x1;
            if (imm_flag){
                uint16_t imm5 = sign_extend(intstr & 0x1F, 5);
                reg[rd] = reg[rs] - imm5;
            }
            else {
                uint16_t rt = (intstr & 0x7);
                reg[rd] = reg[rs] - reg[rt];
            }
            update_flags(static_cast<Register>(rd));
            cout << "Executed SUB: R" << rd << " = " << reg[rd] << endl;
            break;
        }
        

        case (0x05) : { // Opcode for And, Machine code: 0000 0000 0000 0101
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t rs = (intstr >> 6) & 0x7;

            uint16_t imm_flag = (intstr >> 5) & 0x1;

            if (imm_flag){
                uint16_t imm5 = sign_extend(intstr & 0x1F, 5);
                reg[rd] = reg[rs] & imm5;
            }
            else {
                uint16_t rt = (intstr & 0x7);
                reg[rd] = reg[rs] & reg[rt];
            }
            update_flags(static_cast<Register>(rd));
            cout << "Executed AND: R" << rd << " = " << reg[rd] << endl;
            break;
        }

        case 0x09 : { // Not : OpCode: 1001
            // format: [Opcode 4 bit][rd 3 bit][rs 3 bit][111111]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t rs = (intstr >> 6) & 0x7;

            // Update: lc3e_markI : Opcode 1001 : (Not, NEG, SLL, SRL)

            uint16_t FunBit = (intstr >> 4) & 0x3;
            uint16_t AmoBit = (intstr & 0xF);
            switch (FunBit) {
                case 0x03 : {
                    reg[rd] = -reg[rs]; // Bu 2 = Neg
                    break;
                }
                case 0x02 : { // SLL [0,15]
                    reg[rd] = reg[rs] << AmoBit;
                }
                case 0x01 : { // SRL [0,15]
                    reg[rd] = reg[rs] >> AmoBit;
                }
                default : {
                    reg[rd] = ~reg[rs]; // Toan tu ~ thuc hien dao tat ca bit trong thanh ghi nguon (rs)
                }
            }

            update_flags(static_cast<Register>(rd));
            cout << "Executed Extend_Not_NEG_SLL_SRL : R" << rd << " = " << reg[rd] << endl;
            break;
        }

        case 0x02 : { // LD: Machine code: 0000 0000 0000 0010 : Load with the range from PC +- 256 ô nhớ
            // format: [opcode 4 bit][rd 3 bit][offset 9 bit]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);

            uint16_t rb = reg[RPC] + offset; // Address = 0x3000 + offset
            reg[rd] = mem.read(rb); // reg[rd] = ram[rb]

            update_flags(static_cast<Register>(rd));
            cout << "Executed LD:  Load value " << reg[rd]
                 << " from memory [0x" << hex << rb << dec << "] into R" << rd << endl;
            break;
        }

        case 0x03 : { // ST : Machine Code: 0000 0000 0000 0011 : Store word Sw
            // format: [opcode 4 bit][rd 3 bit][offset 9 bit]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);
            
            uint16_t rb = reg[RPC] + offset; // Address = 0x3000 + offset
            mem.write(rb, reg[rd]); // ram[rb] = reg[rd]
            
            cout << "Executed ST: Stored value " << reg[rd]
                 << " from R" << rd << " into memory [0x" << hex << rb << dec << "]" << endl;
            break;
        }

        case 0x0 : { // Branch : Machine code : 0000 0000 0000 0000
            // format: [0000] [n: 1 bit] [z: 1 bit] [p: 1 bit] [PCoffset9: 9 bit].
            uint16_t CFlag = (intstr >> 9) & 0x7; // Condition Flag [3 bit] [9,11]
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);

            if (CFlag & reg[RFlag]){
                reg[RPC] += offset;
            }
            break;
        }

        case 0xC : { // Jump, Machine code : 0000 0000 0000 1100
            // format: 1100 000 [BaseR: 3 bit] 000000

            uint16_t rb = (intstr >> 6) & 0x7; // Base register : 3 bit [6,8]
            reg[RPC] = reg[rb]; // Nhay truc tiep den dia chi luu trong base register
            break;
        }


        case 0x06 : { // LDR, Machine Code: 0000 0000 0000 0110
            // LDR <-> LD but khác nhau ở addressing Mode, có thể di chuyển [0 65536]
            // Format [Opcode 12-15][rd: 9-11][rb: 6-8][offset 0-5]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t rb = (intstr >> 6) & 0x7;

            uint16_t offset = sign_extend(intstr & 0x3F, 6);

            reg[rd] = mem.read(reg[rb] + offset); // reg[rd] = ram[reg[rb] + offset] // Đọc từ RAM và lưu vào DR
            update_flags(static_cast<Register>(rd));
            break;
        }

        case 0x07 : { // STR, Machine Code : 0000 0000 0000 0111
            // Format [Opcode 12-15][rd: 9-11][rb: 6-8][offset 0-5]
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t rb = (intstr >> 6) & 0x7;

            uint16_t offset = sign_extend(intstr & 0x3F, 6);
            uint16_t address = reg[rb] + offset;
            mem.write(address, reg[rd] ); // ram[reg[rb] + offset] = reg[rd]. (Note: Gia tri Reg[rb] phai co truoc do)
            break;
        }

        case 0x0A : { // LDI, Machine Code: 0000 0000 0000 1010
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);

            uint16_t pointer = reg[RPC] + offset;
            uint16_t address = mem.read(pointer);

            reg[rd] = mem.read(address);
            update_flags(static_cast<Register>(rd));
            break;
        }

        /*
            - LD (Load Direct): Format [Opcode 4 bit][rd: 3 bit][offset 9 bit]
            Address = PC + offset
            rg[rd] = ram [Address], range [PC -256, PC + 255], access to Ram: 1
            - LDI (Load Indirect): Format [Opcode 4 bit][rd: 3 bit][offset 9 bit]
                                   Pointer = PC + offset
                                   Address = ram[Pointer]
                                   reg[rd] = ram[Address]
            range [0, 65536], access to ram: 2
            - LDR (Load Register/ Base + Offset): Format [Opcode 4 bit][rd: 3 bit][rb: 3 bit][offset 6 bit]
                                                  Address = reg[rb] + offset
                                                  reg[rd] = ram[Address]
            range [reg[rb] - 32, reg[rb] + 31]access to ram: 1, App: Duyet mang, truy cap trong cau truc du lieu, bo nho Stack.
        */

        case 0x0B : { // STI, Machine Code: 0000 0000 0000 1011
            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);

            uint16_t pointer = reg[RPC] + offset;
            uint16_t address = mem.read(pointer);
            mem.write(address, reg[rd]);
            break;
        }

        case 0x0E : { // LEA : Machine code : 0000 0000 0000 1110
            // format: [opcode 4 bit][rd 3 bit][offset 9 bit]

            uint16_t rd = (intstr >> 9) & 0x7;
            uint16_t offset = sign_extend(intstr & 0x1FF, 9);

            reg[rd] = reg[RPC] + offset;
            update_flags(static_cast<Register>(rd));
            break;
        }

        case 0x4 : { // JSR : Opcode: 0100 : Jump to Subroutine

            // format: [Opcode 4 bit][BitF 1 bit = 1][offset 11 bit] 
            // format: [Opcode 4 bit][BitF 1 bit = 0][00][BaseR 3 bit 6-8][000000] 

            reg[R7] = reg[RPC]; // incremented PC

            uint16_t BitF = (intstr >> 11) & 0x1;
            if (BitF == 0 ){
                uint16_t rb = (intstr >> 6) & 0x7;
                reg[RPC] = reg[rb];
            }
            else{
                reg[RPC] += sign_extend(intstr & 0x7FF, 11);
            }
            break;

        }

        case (0x0F): { // Trap : Opcode : 1111

            /* format: [Opcode 4 bit][0000][TrapVector 8 bit]
            */
            uint16_t TrapVector = intstr & 0xFF;

            switch(TrapVector){
        case 0x20 : { // Getc : 
                    char c = cin.get();
                    reg[R0] = static_cast<uint16_t>(c);
            update_flags(R0);
            break;
                }
        case 0x21: { // OUT: In 1 ký tự lưu trong R0 ra màn hình
            std::cout << static_cast<char>(reg[R0]);
            std::cout.flush();
            break;
        }
        case 0x22: { // PUTS: In một chuỗi ký tự (String) bắt đầu từ địa chỉ lưu trong R0
            uint16_t addr = reg[R0];
            uint16_t c = mem.read(addr);
            while (c != 0x0000) { // Chuỗi ký tự kết thúc bằng ký tự Null (0)
                std::cout << static_cast<char>(c);
                addr++;
                c = mem.read(addr);
            }
            std::cout.flush();
            break;
        }
        case 0x23: { // IN: Hiển thị yêu cầu nhập, nhận 1 ký tự và in ra màn hình
            cout << "Enter a character: ";
            char c = std::cin.get();
            reg[R0] = static_cast<uint16_t>(c);
            cout << c << "\n";
            update_flags(R0);
            break;
        }
        case 0x25: { // HALT: Dừng chương trình
            running = false;
            std::cout << "\n[HALT] CPU halted.\n";
            break;
        }
        default: {
            std::cout << "Unknown TRAP vector: 0x" << std::hex << TrapVector << std::dec << "\n";
            running = false;
            break;
        }
            }
             
             break;
        }


        default:   { // Truong hop khac -> ISA mo rong
            cout << "Unknown opcode: " << op << endl;
            running = false;
            break;
        }
    }
    
}
uint16_t swap16(uint16_t x){ // Tim hieu them cau lenh nay
      return (x << 8) | (x >> 8);  
}
bool CPU::read_image(const string& image_path){ // Tim heiu them 
    ifstream file(image_path, ios::binary);
    if (!file){
        cerr << "Failed to open file: " << image_path << endl;
        return false;
    }

    uint16_t origin;
    file.read(reinterpret_cast<char*>(&origin), sizeof(origin));
    if (!file) return false;
    origin = swap16(origin); 

    reg[RPC] = origin; // PC register jump to this 

    uint16_t intstr;
    uint16_t address = origin;
    while (file.read(reinterpret_cast<char*>(&intstr), sizeof(intstr))) {
        mem.write(address, swap16(intstr));
        address++;
    }

    cout << "Successfully loaded program from " << image_path 
              << " starting at address 0x" << hex << origin << dec << endl;
    return true;
}
