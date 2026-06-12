//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 11:53:44 AM
// Module Name: spi_shift_reg
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_shift_reg(
    input  wire        sys_clk,
    input  wire        sys_rst_n,
    input  wire        fall_en,
    input  wire        rise_en,
    input  wire        load,
    input  wire [15:0] tx_data,
    input  wire        miso,
    input  wire        latch_rx,
    output reg         mosi,
    output reg [15:0]  rx_data
    );

    reg [15:0] tx_shift_reg;
    reg [15:0] rx_shift_reg;

    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            tx_shift_reg <= 16'b0;
            rx_shift_reg <= 16'b0;
            mosi         <= 1'b0;
            rx_data      <= 16'b0;
        end else begin
            if (load) begin
                tx_shift_reg <= tx_data;
                rx_shift_reg <= 16'b0;
                mosi         <= tx_data[15];
            end

            if (rise_en) begin
                rx_shift_reg <= {rx_shift_reg[14:0], miso};
            end

            if (fall_en) begin
                tx_shift_reg <= {tx_shift_reg[14:0], 1'b0};
                mosi         <= tx_shift_reg[14];
            end

            if (latch_rx) begin
                rx_data <= rx_shift_reg;
            end
        end
    end

endmodule