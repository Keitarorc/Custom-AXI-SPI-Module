//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/11/2026 02:35:03 PM
// Module Name: spi_clk_div
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_clk_div (
    input       sys_clk,
    input       sys_rst_n,
    input [7:0] clk_div,
    input       en,
    output reg  sclk,
    output reg  fall_en,
    output reg  rise_en
);

    reg [31:0] counter;

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            counter  <= 32'd0;
            sclk     <= 1'b1;
            fall_en  <= 1'b0;
            rise_en  <= 1'b0;
        end else begin
            rise_en <= 1'b0;
            fall_en <= 1'b0;

            if (!en) begin
                counter <= 32'd0;
                sclk    <= 1'b1;
            end else begin
                if (counter == clk_div) begin
                    counter <= 32'd0;

                    if (sclk) begin
                        sclk    <= 1'b0;
                        fall_en <= 1'b1;
                    end else begin
                        sclk    <= 1'b1;
                        rise_en <= 1'b1;
                    end
                end else begin
                    counter <= counter + 1'd1;
                end
            end
        end
    end

endmodule