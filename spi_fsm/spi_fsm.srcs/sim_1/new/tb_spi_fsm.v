//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/13/2026 10:35:07 AM
// Module Name: tb_spi_fsm
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_spi_fsm;

    reg sys_clk;
    reg sys_rst_n;
    reg spi_en;
    reg start;
    reg fall_en;
    reg rise_en;

    wire sclk;
    wire clk_div_en;
    wire load;
    wire latch_rx;
    wire assert_cs;
    wire deassert_cs;
    wire busy;
    wire done;

    // DUT
    spi_fsm dut (
        .sys_clk(sys_clk),
        .sys_rst_n(sys_rst_n),
        .spi_en(spi_en),
        .start(start),
        .fall_en(fall_en),
        .rise_en(rise_en),
        .sclk(sclk),
        .clk_div_en(clk_div_en),
        .load(load),
        .latch_rx(latch_rx),
        .assert_cs(assert_cs),
        .deassert_cs(deassert_cs),
        .busy(busy),
        .done(done)
    );

    // 50 MHz clock -> 20 ns period
    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    integer i;

    initial begin
        // Initial values
        sys_rst_n = 1'b0;
        spi_en    = 1'b0;
        start     = 1'b0;
        fall_en   = 1'b0;
        rise_en   = 1'b0;

        // Hold reset
        repeat (3) @(posedge sys_clk);
        sys_rst_n = 1'b1;

        // Enable SPI
        @(posedge sys_clk);
        spi_en = 1'b1;

        // Pulse start for one clock
        @(posedge sys_clk);
        start = 1'b1;
        @(posedge sys_clk);
        start = 1'b0;

        // Wait a cycle so FSM enters TRANSFER
        @(posedge sys_clk);

        // Generate 16 SPI bit events
        for (i = 0; i < 20; i = i + 1) begin
            // falling edge pulse
            @(posedge sys_clk);
            fall_en = 1'b1;
            @(posedge sys_clk);
            fall_en = 1'b0;

            // rising edge pulse
            @(posedge sys_clk);
            rise_en = 1'b1;
            @(posedge sys_clk);
            rise_en = 1'b0;
        end
        
        
        // Pulse start for one clock
        @(posedge sys_clk);
        start = 1'b1;
        @(posedge sys_clk);
        start = 1'b0;
        
        for (i = 0; i < 10; i = i + 1) begin
            // falling edge pulse
            @(posedge sys_clk);
            fall_en = 1'b1;
            @(posedge sys_clk);
            fall_en = 1'b0;

            // rising edge pulse
            @(posedge sys_clk);
            rise_en = 1'b1;
            @(posedge sys_clk);
            rise_en = 1'b0;
        end
        
        @(posedge sys_clk);
        spi_en = 1'b0;
        
        for (i = 0; i < 20; i = i + 1) begin
            // falling edge pulse
            @(posedge sys_clk);
            fall_en = 1'b1;
            @(posedge sys_clk);
            fall_en = 1'b0;

            // rising edge pulse
            @(posedge sys_clk);
            rise_en = 1'b1;
            @(posedge sys_clk);
            rise_en = 1'b0;
        end

        // Wait a few more clocks to observe DONE -> IDLE
        repeat (10) @(posedge sys_clk);

        $finish;
    end

    initial begin
        $display("time\trst_n\tspi_en\tstart\tfall_en\trise_en\tsclk\tclk_div_en\tload\tlatch_rx\tassert_cs\tdeassert_cs\tbusy\tdone");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t\t%b\t%b\t\t%b\t\t%b\t\t%b\t%b",
                 $time, sys_rst_n, spi_en, start, fall_en, rise_en,
                 sclk, clk_div_en, load, latch_rx, assert_cs, deassert_cs, busy, done);
    end

endmodule
