/* 
    Khoi nay dung de cap nhat co flag va na du lieu cho thanh ghi thong qua tin hieu reg_write_flag, dong thoi
    dam bao thanh ghi $s0 = 0 (lc3e - extended)
*/


module registers_file (
    input wire clk,
    input wire reset,
    input wire reg_write_flag, // Tin hieu write thanh ghi

    input wire [2:0] rd, // Thanh ghi dich
    input wire [2:0] rs, // Thanh ghi nguon 1
    input wire [2:0] rt, // Thanh ghi nguon 2
    input wire [15:0] reg_write_data,
    input wire [15:0] r_result, // reg[result] = reg[rs] + reg[rt] or reg[rs] + imm5
    output wire [15:0] rs_value, // reg[rs] : gia tri thanh ghi nguon 1
    output wire [15:0] rt_value, // reg[rt] or imm5 (expand to 16 bit)
    output reg [2:0] rflag // Co trang thai [2]=Neg, [1]=Zer, [0]=Pos

);

reg [15:0] registers [7:0]; // Memory Array: reg [width] <name_> [number] : 8 thanh ghi 16 bit
assign rs_value = (rs == 3'b000) ? 16'h0000 : registers[rs]; // Expand instructions from lc3 -> R0 is always the $zero
assign rt_value = (rt == 3'b000) ? 16'h0000 : registers[rt]; 

// constants cho rflag
    localparam rzer = 3'b010; // Cờ Zero (Z)
    localparam rneg = 3'b100; // Cờ Negative (N)
    localparam rpos = 3'b001; // Cờ Positive (P)

// write data and update flag
integer i;

always @(posedge clk or posedge reset) begin // theo tung chu ky (rising edge of clk or reset)
    if (reset) begin // Tin hieu reset dua toan bo thanh ghi ve gia tri 0x00;
        for (i = 0; i < 8; i++) begin
            registers[i] <= 16'h0000;
            end
        rflag <= rzer;
            end 
    else if (reg_write_flag) begin // neu co tin hieu cho phep ghi thi write gia tri vao thanh ghi dich
        if (rd == 3'b000) begin // kt thanh ghi dich co la $zero ?
            rflag <= rzer;
            end 
        else begin
            registers[rd] <= r_result; // Ghi du lieu vao thanh ghi

            // Cap nhat co
            if (reg_write_data == 16'h0000) begin
                rflag <= rzer;
                end
            else if (r_result[15] == 1'b1) begin
                rflag <= rneg; // kiem tra bit dau ngoai cung la so am
                end
            else begin
            rflag <= rpos;
                end
        end
    end
end
endmodule
