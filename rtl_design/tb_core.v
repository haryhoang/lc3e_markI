/*
testbench: iverilog -y . -s core -o /dev/null core.v


*/

`timescale 1ns/1ps //  time emulator là nanogiây

module tb_core();
    reg clk;
    reg reset;

    core lc3 (
        .clk(clk),
        .reset(reset)
    );

   
    always begin  // Tao clk mo phong, f = 50 MHz, mot chu ky hoan chinh 0 -> 1 -> 0 = 10 + 10 = 20ns
        #10 clk = ~clk; // 10ns đảo xung clk : 1 -> 0 và reverse
    end
    initial begin // Xuat du lieu dang song
    $dumpfile("wave.vcd"); // name = wave.vcd
    $dumpvars(0, tb_core);
    end

    // 4. Kịch bản mô phỏng
    initial begin
        #0;
        clk = 0;
        reset = 1; 
        #40; // Giu reset trong 40ns
        reset = 0; // Tắt Reset để CPU bắt đầu chu trình FETCH lệnh
        #5000; 
  
        $display("Simulation Finished!");
        $finish; // dung mo phong
    end
endmodule

/* 
# 1. Biên dịch lại
iverilog -o core_sim tb_core.v core.v pc_unit.v instruction_memory.v sign_extend.v controller.v registers_file.v alu.v data_memory.v

# 2. Chạy mô phỏng để tạo file wave.vcd
vvp core_sim

gtkwave wave.vcd


initial begin: chạy một lần từ t = 0ns -> timeout

*/