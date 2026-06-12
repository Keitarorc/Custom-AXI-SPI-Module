//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 08:09:29 PM
// Module Name: spi_cs_ctrl
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_cs_ctrl(
    input sys_clk,
    input sys_rst_n,
    input assert_cs,
    input deassert_cs,
    output reg cs_n
    );

    reg assert_cs_d;
    reg deassert_cs_d;

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            cs_n          <= 1'b1;
            assert_cs_d   <= 1'b0;
            deassert_cs_d <= 1'b0;
        end else begin
            assert_cs_d   <= assert_cs;
            deassert_cs_d <= deassert_cs;

            if (assert_cs_d) begin
                cs_n <= 1'b0;
            end else if (deassert_cs_d) begin
                cs_n <= 1'b1;
            end
        end
    end
endmodule