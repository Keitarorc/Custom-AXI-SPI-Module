//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 09:29:09 PM
// Module Name: tb_spi_cs_ctrl
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_spi_cs_ctrl;

    reg  sys_clk;
    reg  sys_rst_n;
    reg  assert_cs;
    reg  deassert_cs;
    wire cs_n;

    spi_cs_ctrl dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        .cs_n(cs_n)
    );

    // 50 MHz clock -> 20 ns period
    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    initial begin
        // initialize inputs
        sys_rst_n    = 1'b0;
        assert_cs    = 1'b0;
        deassert_cs  = 1'b0;

        // hold reset for a couple clocks
        repeat (2) @(posedge sys_clk);
        sys_rst_n = 1'b1;

        // wait one cycle
        @(posedge sys_clk);

        // pulse assert_cs for one clock
        assert_cs = 1'b1;
        @(posedge sys_clk);
        assert_cs = 1'b0;

        // wait and observe cs_n go low one clock later
        repeat (3) @(posedge sys_clk);

        // pulse deassert_cs for one clock
        deassert_cs = 1'b1;
        @(posedge sys_clk);
        deassert_cs = 1'b0;

        // wait and observe cs_n go high one clock later
        repeat (3) @(posedge sys_clk);

        $finish;
    end

    initial begin
        $display("time\tclk\trst_n\tassert_cs\tdeassert_cs\tcs_n");
        $monitor("%0t\t%b\t%b\t%b\t\t%b\t\t%b",
                 $time, sys_clk, sys_rst_n, assert_cs, deassert_cs, cs_n);
    end

endmodule

