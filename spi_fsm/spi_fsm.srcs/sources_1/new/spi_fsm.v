//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/12/2026 10:04:13 PM
// Module Name: spi_fsm
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module spi_fsm(
    input  wire sys_clk,
    input  wire sys_rst_n,
    input  wire spi_en,
    input  wire start,
    input  wire fall_en,
    input  wire rise_en,
    output reg  sclk,
    output reg  clk_div_en,
    output reg  load,
    output reg  latch_rx,
    output reg  assert_cs,
    output reg  deassert_cs,
    output reg  busy,
    output reg  done
    );

    localparam IDLE     = 2'b00;
    localparam TRANSFER = 2'b01;
    localparam DONE_ST  = 2'b10;

    reg [1:0] current_state, next_state;
    reg [5:0] counter, next_counter;

    // State and counter registers
    always @(posedge sys_clk) begin
        if (!sys_rst_n) begin
            current_state <= IDLE;
            counter       <= 6'd0;
        end else begin
            current_state <= next_state;
            counter       <= next_counter;
        end
    end

    // Next-state logic and outputs
    always @(*) begin
        // defaults
        next_state   = current_state;
        next_counter = counter;

        sclk         = 1'b1;
        clk_div_en   = 1'b0;
        load         = 1'b0;
        latch_rx     = 1'b0;
        assert_cs    = 1'b0;
        deassert_cs  = 1'b0;
        busy         = 1'b0;
        done         = 1'b0;

        case (current_state)
            IDLE: begin
                sclk = 1'b1;
                if (spi_en && start) begin
                    load       = 1'b1;
                    assert_cs  = 1'b1;
                    next_counter = 6'd0;
                    next_state = TRANSFER;
                end
            end

            TRANSFER: begin
                clk_div_en = 1'b1;
                busy       = 1'b1;

                if (fall_en) begin
                    sclk = 1'b0;
                end

                if (rise_en) begin
                    sclk = 1'b1;
                    if (counter == 6'd15) begin
                        latch_rx   = 1'b1;
                        next_state = DONE_ST;
                    end else begin
                        next_counter = counter + 1'b1;
                    end
                end
            end

            DONE_ST: begin
                sclk        = 1'b1;
                done        = 1'b1;
                deassert_cs = 1'b1;
                next_state  = IDLE;
            end

            default: begin
                next_state   = IDLE;
                next_counter = 6'd0;
            end
        endcase
    end

endmodule