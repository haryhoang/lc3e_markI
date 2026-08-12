/*

- Khoi nay dung de cap nhat cau lenh, nap cau lenh moi tu UART.

    address           (ram[address] = ram_value )
    [0x0000]          --->   [0001_001_000_1_00101] (Lệnh ADD 16-bit)
    [0x0001]          --->   [0001_010_001_1_01010] (Lệnh ADD 16-bit)
    ...               --->   ...
Note: Address trong rram khai bao voi kich thuoc 4K o nho cho tien quan ly, 
trong bus cong nghiep -> 32 bit, 16 bit,.. toi uu 12 bit nen lam o phan core -> han che sua code o cac module khac
khi muon nang cap or thay doi bus .

in extend lc3 (lc3e), i use 2^12 address = 4096 block for store value, with the width of 1 block is 16 bit

Dual port ram
┌─────────────────────────────┐
 CPU (Cửa A) ──►  CỔNG ĐỌC (Read Port)        │
                │  - address                  │
                │  - instruction              │  RAM 4K ô nhớ
                │                             │  (Block RAM)
UART Loader  ──►  CỔNG GHI (Write Port)       │
 (Cửa B)        │  - write_addrress           │
                │  - write_data               │
                │  - write_enable             │
                └─────────────────────────────┘

CPU: Noi chua cau lenh duoc viet san trong ram, CPU lien tuc doc de xu ly
UART loader: dung de giao tiep voi fpga, co the cho phep nap lenh moi vao cho may tinh (dua vao Ram)

*/

module instruction_memory(
    input wire clk,
    input wire [15:0] address, // address of the instruction equivalent
    input wire write_enable, // tin hieu cho phep ghi neu co tin hieu UART (UART)
    input wire [15:0] write_address, // dia chi ghi (UART)
    input wire [15:0] write_data, // du lieu can nap (UART)
    output wire [15:0] instruction // lenh tra ve cpu de decode
);


initial begin 
        // Nạp file chương trình tên là "program.hex" vào bộ nhớ RAM ảo
        $readmemh("program.hex", ram);
    end

// Su dung 4K o ram, moi o rong 16 bit
    reg [15:0] ram [0:4095];
    assign instruction = ram[address[11:0]]; // cap nhat cau lenh

    always @(posedge clk) begin // hoat dong theo rising edge cua clj=k
        if (write_enable) begin // Neu tin hieu tu UART (connect va cho phep nap vao ram)
            ram[write_address[11:0]] <= write_data; // Luu tru cau lenh nap vao ram[address] co address tuong ung
        end
    end
endmodule

/*
always @(*) : 1 tin hieu thay doi, chay lai logic ngay lap tuc
always @(posedge clk) : tao ra cac o nho (d ff), it only rung when the clk is rising
thay doi gia tri khi rising edge


Note: t
*/