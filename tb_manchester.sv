`timescale 1ns/1ps

module tb_manchester;
    logic [7:0] ui_in  = 8'h00;
    logic [7:0] uo_out;
    logic [7:0] uio_in = 8'h00;
    logic [7:0] uio_out;
    logic [7:0] uio_oe;
    logic       ena    = 1'b1;
    logic       clk    = 1'b0;
    logic       rst_n  = 1'b0;

    tt_um_manchester_encoder dut (
        .ui_in   (ui_in),
        .uo_out  (uo_out),
        .uio_in  (uio_in),
        .uio_out (uio_out),
        .uio_oe  (uio_oe),
        .ena     (ena),
        .clk     (clk),
        .rst_n   (rst_n)
    );

    always #25 clk = ~clk; // 20 MHz

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_manchester);

        // Reset
        #100;
        rst_n = 1'b1;
        @(posedge clk);

        // Load 4 bytes: A5, 5A, 12, 34 (uio_in[0] = load)
        uio_in[0] = 1'b1;
        ui_in = 8'hA5; @(posedge clk);
        ui_in = 8'h5A; @(posedge clk);
        ui_in = 8'h12; @(posedge clk);
        ui_in = 8'h34; @(posedge clk);
        uio_in[0] = 1'b0;
        @(posedge clk);

        // Start (uio_in[1] = start)
        uio_in[1] = 1'b1; @(posedge clk);
        uio_in[1] = 1'b0;

        // Wait for done (uo_out[2])
        wait (uo_out[2] == 1'b1);
        #200;
        $display("SIMULATION PASSED: done=1");
        $finish;
    end
endmodule
