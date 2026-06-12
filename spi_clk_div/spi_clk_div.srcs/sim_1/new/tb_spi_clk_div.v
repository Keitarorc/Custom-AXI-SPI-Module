//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 10:40:20 AM
// Module Name: tb_spi_clk_div
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_spi_clk_div;

    localparam integer SYSTEM_CLK = 50_000_000;

    reg                   sys_clk;
    reg                   sys_rst_n;
    reg  [7:0]            clk_div;
    reg                   en;
    wire                  fall_en;
    wire                  rise_en;

    // DUT
    spi_clk_div #(
        .SYSTEM_CLK(SYSTEM_CLK)
    ) dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .clk_div(clk_div),
        .en(en),
        .fall_en(fall_en),
        .rise_en(rise_en)
    );

    // 50 MHz clock => 20 ns period
    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    // Stimulus
    initial begin
        sys_rst_n = 1'b0;
        clk_div   = 16'd4;   // toggle every 5 sys_clk cycles
        en        = 1'b0;

        // hold reset for a few cycles
        #100;
        sys_rst_n = 1'b1;

        // enable divider
        #40;
        en = 1'b1;

        // run for a while
        #1000;

        // change divider on the fly
        clk_div = 16'd9;     // toggle every 10 sys_clk cycles
        #1500;

        // disable
        en = 1'b0;
        #200;

        $finish;
    end

    // Monitor edge pulses
    initial begin
        $display("Time\treset\ten\tclk_div\trise_en\tfall_en");
        $monitor("%0t\t%b\t%b\t%0d\t%b\t%b",
                 $time, sys_rst_n, en, clk_div, rise_en, fall_en);
    end

    // Optional: message only when pulses occur
    always @(posedge sys_clk) begin
        if (rise_en)
            $display("[%0t] RISE pulse detected", $time);
        if (fall_en)
            $display("[%0t] FALL pulse detected", $time);
    end

endmodule