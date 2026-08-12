/* --- description function block  -----



*/
module core (
    input wire clk,
    input wire reset,
    
    // Cac cong ket noi UART (neu can nap chuong trinh tu ben ngoai)
    input wire write_enable_UART,
    input wire [15:0] write_address_UART,
    input wire [15:0] write_data_UART
);

// internal wires
    wire [15:0] pc;                 // dia chi cau lenh hien tai
    wire [15:0] pc_incremented;     // dia chi cau lenh ke tiep
    wire [15:0] instruction;        // lenh can xu ly

    wire [3:0]  alu_control;        // tin hieu 4 bit kiem tra thuc hien phep tinh
    wire        reg_write_flag;     // tin hieu cho phep ghi vao thanh ghi
    wire [1:0]  pc_select;          // chon nguon cap nhat PC
    wire        alusrc;             // Chon tin hieu imm5 or rt (0: Reg, 1: Imm)
    wire [1:0]  regwritesrc;        // Chon nguon ghi vao Reg (0: ALU, 1: Mem, 2: PC+1)
    wire        mem_write_flag;     // tin hieu cho phep ghi vao ram/ bo nho

    wire [15:0] extend_out;         // gia tri sau khi mo rong thanh 16 bit
    wire [15:0] rs_value, rt_value; // gia tri cua thanh ghi 1, thanh ghi 2
    wire [15:0] alu_b;              // Dau vao B cua ALU (sau MUX)
    wire [15:0] alu_out;
    wire [15:0] read_data;          // du lieu tu bo nho: ram[address]
    reg  [15:0] reg_write_data;     // BIEN DOI THANH REG (Ghi trong always block)
    wire [2:0]  rflag;
        // Khoi to hop
        // MUX chon dau vao B cho ALU (rt_value hoac Immediate)
assign alu_b = (alusrc) ? extend_out : rt_value;
 

// 2. PC management
pc_unit pc_unit_instruction (
    .clk(clk),
    .reset(reset),
    .pc_select(pc_select),
    .pc_offset(extend_out),
    .r_base(rs_value), // format: [Opcode 4 bit][rd: 3 bit][rb: 3 bit][offset 6 bit], rb = rs
    .pc(pc),
    .pc_incremented(pc_incremented)
);

// 3. Instruction Memory 
instruction_memory imem (
    .clk(clk),
    .address(pc),
    .write_enable(write_enable_UART), // tin hieu cho phep nap chuong trinh qua UART
    .write_address(write_address_UART), //  nap dia chi UART
    .write_data(write_data_UART), // nap du lieu qua UART
    .instruction(instruction) 
);

// 4. Sign Extend
sign_extend sign_extend_instruction (
    .instruction(instruction),
    .opcode(instruction[15:12]), // Xem ma lenh de biet dua thanh phan nao vao sign_extend va can mo rong
    .extend_out(extend_out) // gia tri dau ra (16 bit)
);

// 5. Controller 
controller controller_instruction (
    .opcode(instruction[15:12]),
    .funcbit(instruction[5:4]),
    .alu_control(alu_control),
    .reg_write_flag(reg_write_flag),
    .mem_write_flag(mem_write_flag),
    .regwritesrc(regwritesrc),
    .pc_select(pc_select),
    .alusrc(alusrc)
);

// 6. Register File
registers_file registers_file_instruction (
    .clk(clk),
    .reset(reset),
    .reg_write_flag(reg_write_flag),
    .rd(instruction[11:9]),
    .rs(instruction[8:6]),
    .rt(instruction[2:0]), // imm_flag == 0 -> bit [0,2] : rt (register s2), imm_flag == 1 -> bit [0, 4] : const (hang so)
    .reg_write_data(reg_write_data),
    .rs_value(rs_value),
    .rt_value(rt_value),
    .rflag(rflag)
);


// 7. Khoi tinh toan ALU
alu alu_instruction(
    .alu_a(rs_value),
    .alu_b(alu_b),              // Truyen alu_b da qua MUX
    .shamt(instruction[3:0]),
    .alu_control(alu_control),
    .alu_out(alu_out)           
);

// 8. Bo nho du lieu (RAM)
data_memory data_memory_instruction (
    .clk(clk),
    .address(alu_out),
    .mem_write_flag(mem_write_flag), // tin hieu cho phep ghi vao bo nho / nap vao ram/ memory
    .mem_write_data(rs_value), // du lieu ghi vao trong ram/ memory
    .read_data(read_data)
);

// MUX chon nguon ghi vao Register File
            always @(*) begin
                case (regwritesrc)
                    2'b01:   reg_write_data = read_data;                   // Load tu RAM (LD)
                    2'b10:   reg_write_data = pc_incremented;              // Return PC (JSR/CALL)
                    2'b11:   reg_write_data = pc_incremented + extend_out;
                    default: reg_write_data = alu_out;                     // Kết quả ALU
                endcase
            end
endmodule




/* -- Rules:
1: wire la soi  day dong (not store), all the bus connect all the module together at file core is wire
2: reg la o nho (luu tru du lieu)
input (wire)

*/
