/*
- Lc3 architecture: dia chi co do rong 16 bit (quy uoc 16 bit = 1 word = 2 byte)
    0x3000 – 0xFDFF (User Program Space): Vùng nhớ dành cho chương trình người dùng.
     Đây là lý do khi reset, giá trị PC luôn được nạp mặc định là 16'h3000 để bắt đầu chạy câu lệnh đầu tiên của người dùng.


    This Block dung de cap nhat gia tri cho pc
    quan ly thanh ghi pc, at rising clk, pc += 1 (kien truc lc3), nguon nap cho pc phu thuoc vao tin hieu dieu khien tu pc_mux from controller.
*/

module pc_unit (
    input wire clk,
    input wire reset,
    input wire [1:0] pc_select, // tin hieu chon cach cap nhat gia tri pc ke tiep
    input wire [15:0] pc_offset, // su dung cho cac cau lenh st, ld,..
    input wire [15:0] r_base, // dia chi base
    output reg [15:0] pc, // dia chi hien tai
    output reg [15:0] pc_incremented // dia chi hien tai + 1
);

// pc += 1
always @(*) begin
    pc_incremented = pc + 16'b0001; // luon luon tinh toan, cap nhat gia tri pc_incremented
end

// upddate pc to clk
always @(posedge clk or posedge reset) begin // thay doi theo rising edge (chu ky)
    if (reset) begin
        pc <= 16'h3000; // reset dia chi mac dinh pc in lc3
    end
    else begin
        case (pc_select)
            2'b01: pc <= pc_incremented + pc_offset; // pc_select = 1 : br, jsr, ls, lt
    
            2'b00: pc <= r_base; // pc_select = 0 : jmp, jsrr

            default : pc <= pc_incremented;
        endcase
    end
end
endmodule

/*
 
            - LD (Load Direct): Format [Opcode 4 bit][rd: 3 bit][offset 9 bit]
            Address = PC+1 + offset
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