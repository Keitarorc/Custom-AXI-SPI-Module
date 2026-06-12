//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 08:09:29 PM
// Module Name: spi_cs_ctrl
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_cs_ctrl(
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire assert_cs,
    input  wire deassert_cs,
    output reg  cs_n
);

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            cs_n <= 1'b1;
        end else begin
            if (assert_cs)
                cs_n <= 1'b0;
            else if (deassert_cs)
                cs_n <= 1'b1;
        end
    end
endmodule