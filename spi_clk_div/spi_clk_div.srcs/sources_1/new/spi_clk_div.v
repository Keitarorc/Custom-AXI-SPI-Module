//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/11/2026 02:35:03 PM
// Module Name: spi_clk_div
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_clk_div #(
    parameter SYSTEM_CLK = 50_000_000
    )
    (
    input       sys_clk,
    input       sys_rst_n,
    input [7:0] clk_div,
    input       en,
    output reg  fall_en,
    output reg  rise_en
    );
    
    reg [31:0] counter;
    reg SCLK;
    
    //If the sys_rst_n is '0' the clears every output and internal counter
    always @(posedge sys_clk) begin
        //Resets signals and internal counter when sys_rst_n '0'
        if (!sys_rst_n) begin
            counter <= 32'd0;
            SCLK <= 1'b0;
            fall_en <= 1'b0;
            rise_en <= 1'b0;  
        //When sys_rst_n is '1'    
        end else begin
            rise_en <= 1'b0;
            fall_en <= 1'b0;
            //If en is '0' then not SCLK generated or internal counter
            if (!en) begin
                counter <= 32'b0;
                SCLK <= 1'b0;
            //Else if counter counts to clk_div then NOT SCLK, else adds to counter
            end else begin
                if (counter == clk_div) begin
                    counter <= 32'b0;
                    //Generates rise_en and fall_en pulses
                    if (SCLK) begin
                        SCLK <= 1'b0;
                        fall_en <= 1'b1;
                    end else begin
                        SCLK <= 1'b1;
                        rise_en <= 1'b1;
                    end
                end else begin
                    counter <= counter + 1'd1;
                end
            end
        end
    end
endmodule
