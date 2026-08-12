/*


- Khoi nay dua vao opcode (va funcbit doi voi opcode = 1001) de cung cap cac tin hieu cho alu, ram va thanh ghi,
cu the cho biet
    - voi opcode va funcbit thi chuc nang hoat dong cua alu nay la gi: (alu_control)
    - gia tri nay co duoc  ghi vao thanh ghi ko (reg_write_flag)
    - gia tri nay co duoc ghi vao bo nho / ram hay ko (mem_write_flag)
    - gia tri nap vao alu (toan hang thu 2) la gi: imm5 hay la gia tri thanh ghi (rt) (thanh ghi 2) : (alusrc)
    - gia tri duoc phep nap vao thanh ghi den tu dau (ram[address], reg[rs] + reg[rt], reg[rs] + imm5, reg[address],..) : (regwritesrc)
*/



module controller ( 
    input wire [15:12] opcode,
    input wire [5:4]   funcbit,     // 2 bit phân biệt các lệnh mở rộng thuộc Opcode 1001

    output reg [3:0]   alu_control, // Mã điều khiển khối ALU
    output reg         reg_write_flag,    // Cờ cho phép ghi vào Register File
    
    // Bổ sung các cổng điều khiển để kết nối với core.v
    output reg         mem_write_flag,   // Cờ ghi RAM
    output reg         alusrc,      // Chọn ngõ vào ALU (0: Reg 2, 1: Immediate5)
    output reg [1:0]   regwritesrc, // Chọn nguồn ghi vao Register File (00: ALU, 01: RAM, 10: PC+1)
    output reg [1:0]   pc_select    // Chọn nguồn cập nhật PC (00: PC+1, 01: Branch/Jump...)
);

    always @(*) begin
        // Gán giá trị mặc định 
        reg_write_flag    = 1'b0; // 
        alu_control = 4'b0000;
        mem_write_flag   = 1'b0; // Ko ghi
        alusrc      = 1'b0; // Ngo vao Alu: thanh ghi rt
        regwritesrc = 2'b00; // Chon nguon ghi reg -> ket qua tu ALU nap vao
        pc_select   = 2'b00; // Chon gia tri dia chi PC sau do: pc_incremented

        case(opcode)
            4'b0001: begin // ADD
                reg_write_flag    = 1'b1;
                alu_control = 4'b0000;
                alusrc      = 1'b0;
            end
            
            4'b1101: begin // SUB
                reg_write_flag    = 1'b1;
                alu_control = 4'b0001;
                alusrc      = 1'b0;
            end
            
            4'b0101: begin // AND
                reg_write_flag    = 1'b1;
                alu_control = 4'b0010;
                alusrc      = 1'b0;
            end
            
            4'b1001: begin // Nhóm lệnh mở rộng (NOT, NEG, SLL, SRL)
                reg_write_flag = 1'b1;
                case (funcbit)
                    2'b11:   alu_control = 4'b0100; //  (NEG) if funcbit = 11
                    2'b01:   alu_control = 4'b0101; //  (SLL)
                    2'b10:   alu_control = 4'b0110; //  (SRL)
                    default: alu_control = 4'b0011; //  (NOT)
                endcase

                // alusrc: o day khong can thiet vi ta chi can thanh ghi rs (thanh ghi 1), ko can thanh ghi 2 hay immediate
            end

            4'b0010, 4'b0110, 4'b1010, 4'b1110: begin // Các lệnh đọc RAM (LD, LDR, LDW...)
                reg_write_flag    = 1'b1; // Cho phep ghi vao thanh ghi dich (rd)
                regwritesrc = 2'b01; // Chọn dữ liệu từ RAM để ghi vào thanh ghi 
                alusrc      = 1'b1;  // Dùng địa chỉ offset Immediate (gia tri dia vao alu la imm5), dung de tinh dia chi cua ram
            end

            4'b0011, 4'b0111: begin // Các lệnh ghi RAM (ST, STR...)
                mem_write_flag   = 1'b1; // Tin hieu cho phep ghi vao Ram
                alusrc      = 1'b1; // Tin hieu cho biet gia tri nap vao alu la imm5 -> tinh address cua ram
            end

            default: begin
                reg_write_flag    = 1'b0;
                mem_write_flag   = 1'b0;
                alu_control = 4'b0000;
            end
        endcase
    end
endmodule



    