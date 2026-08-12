/*

*/

module sign_extend(
    input wire [15:0] instruction, // cau lenh
    input wire [3:0] opcode, // opcode from controller.
    output reg [15:0] extend_out
);

always @(*) begin
    case (opcode)
    4'b0001, 4'b1101, 4'b0101: begin
        // add (0x01), sub (0xD), and (0x5)
        extend_out = {{11{instruction[4]}}, instruction[4:0]}; // Mo rong bit dau cua imm5
        // format: [Opcode 4 bit][rd 3 bit][rs 3 bit][imm_flag 1 bit][imm5 5 bit]
    end

    /* Toán tử lặp lại {N{bit}}: Nhân bản bit đó N lần. 
    (Ví dụ: {5{1'b1}} thanh 5'b11111).
    Toán tử ghép chuỗi {A, B}: Nối chuỗi bit A và chuỗi bit B lại với nhau.
    */
        // ldr(0x6), str (0x7): 
    4'b0110, 4'b0111: begin //  format [Opcode 12-15][rd: 9-11][rb: 6-8][offset 0-5] 
        extend_out = {{10{instruction[5]}}, instruction[5:0]}; // mo rong offset 5 bit 
    end 
    
       // Kéo dài dấu 9-bit (bit [8:0])
       // LD (0x02), ST (0x03), BR (0x00), LDI (0x0A), STI (0x0B), LEA (0x0E):
    4'b0010, 4'b0011, 4'b0000, 4'b1010, 4'b1011, 4'b1110: begin //  format: [opcode 4 bit][rd 3 bit][offset 9 bit]
        extend_out = {{7{instruction[8]}}, instruction[8:0]}; // mo rong offset -> 16 bit
    end    

            // JSR (0x04): Kéo dài dấu 11-bit (bit [10:0])
            // format: [Opcode 4 bit][BitF 1 bit = 1][offset 11 bit] 
            // format: [Opcode 4 bit][BitF 1 bit = 0][00][BaseR 3 bit 6-8][000000] 
    4'b0100: begin
        extend_out = {{5{instruction[10]}}, instruction[10:0]};
    end   
    
    default: extend_out = 16'h0000;
    endcase
end
endmodule