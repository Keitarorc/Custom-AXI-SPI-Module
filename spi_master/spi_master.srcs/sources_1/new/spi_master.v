//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/13/2026 11:31:32 AM
// Module Name: spi_master
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_master(
    input sys_clk,
    input sys_rst_n,
    input spi_en,
    input [7:0] clk_div,
    input start,
    input [15:0] tx_data,
    input miso,
    
    output cs_n,
    output sclk,
    output mosi,
    output [15:0] rx_data,
    output busy,
    output done
    );
    
    wire fall_en;
    wire rise_en;
    wire clk_div_en;
    wire load;
    wire latch_rx;
    wire assert_cs;
    wire deassert_cs;
    
    spi_fsm spi_fsm_inst_ (
        //inputs
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .spi_en(spi_en),
        .start(start),
        .fall_en(fall_en),
        .rise_en(rise_en),
        
        //outputs
        .sclk(sclk),
        .clk_div_en(clk_div_en),
        .load(load),
        .latch_rx(latch_rx),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        .busy(busy),
        .done(done)
    );
    
    spi_cs_ctrl spi_cs_ctrl_inst_ (
        //inputs
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        
        //outputs
        .cs_n(cs_n)
    );
    
    spi_shift_reg spi_shift_reg_inst_ (    
        //inputs
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .fall_en   (fall_en),
        .rise_en   (rise_en),
        .load      (load),
        .tx_data   (tx_data),
        .miso      (miso),
        .latch_rx  (latch_rx),
        
        //outputs
        .mosi      (mosi),
        .rx_data   (rx_data)
    );
    
    localparam integer SYSTEM_CLK = 50_000_000;
    spi_clk_div #(
        .SYSTEM_CLK(SYSTEM_CLK)
    ) spi_clk_div_inst_ (
        //inputs
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .clk_div(clk_div),
        .en(clk_div_en),
        
        //outputs
        .fall_en(fall_en),
        .rise_en(rise_en)
    );
endmodule
