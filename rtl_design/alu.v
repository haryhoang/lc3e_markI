/*
khoi nay dua vao alu_control de thuc hien phep tinh voi dau vao la gia tri 16 bit den tu hai thanh ghi hoac gia tri 16 bit
tu mot o nho trong ram/ memory,
dau ra la alu_out: ket qua tinh toan

*/

module alu(
    input wire [15:0] alu_a, // gia tri thanh ghi 1
    input wire [15:0] alu_b, // gia tri thanh ghi 2
    input wire [3:0] shamt, // apply for 0x3 : not, neg, srl, sll (shift amount bit)
    input wire [3:0] alu_control, // tin hieu quyet dinh phep tinh cpu (new index)
    output reg [15:0] alu_out // ket qua tinh toan
);

    always @(*) begin
        case (alu_control)

            4'b0000: alu_out = alu_a + alu_b;         // ADD
            4'b0001: alu_out = alu_a - alu_b;         // SUB
            4'b0010: alu_out = alu_a & alu_b;         // AND
            4'b0011: alu_out = ~alu_a;                // NOT (đảo bit)
            4'b0100: alu_out = -alu_a;                // NEG (đổi dấu bù 2)
            4'b0101: alu_out = alu_a << shamt;        // SLL (dịch trái theo AmoBit)
            4'b0110: alu_out = alu_a >> shamt;        // SRL (dịch phải theo AmoBit)

            default: alu_out = 16'h0000;
        endcase
    end
endmodule
