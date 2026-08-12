/*
Kien truc harvard:
Data memory: khoi module nay dung de luu tru cac bien tam, ket qua sau khi qua khoi ALU (Mips cung co khoi nay) thi du lieu trung gian co the duoc
 nap lai vao reg hoac luu tru tam thoi cho cac lenh nhu ld, st, ldr, str, ldi, sti

*/

module data_memory (
    input wire clk,
    input wire [15:0] address, // dia chi ket qua tinh toan tu alu or pc, 
    // co the duoc dung de truy cap vao gia tri cua o nho trong ram (read/write)

    input wire mem_write_flag, // tin hieu cho phep ghi vao ram (memory = bo nho)
    input wire [15:0] mem_write_data, // du lieu can ghi vao ram (ST)
    output wire [15:0] read_data // du lieu doc tu ram, (LD)
);

reg [15:0] ram [4095:0]; // khai bao ram_data 4K o nho
assign read_data = ram[address[11:0]]; // xuat ra gia tri cua ram khi co address thay doi

always @(posedge clk) begin // hoat dong theo xung nhip clk, nap gia tri cho ram
    if (mem_write_flag) begin
        ram[address[11:0]] <= mem_write_data;
    end
end
endmodule
