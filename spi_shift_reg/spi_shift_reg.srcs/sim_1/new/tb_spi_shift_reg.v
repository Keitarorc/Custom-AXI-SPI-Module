//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho 
// Create Date: 04/12/2026 07:56:01 PM 
// Module Name: tb_spi_shift_reg
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_spi_shift_reg;

    reg         sys_clk;
    reg         sys_rst_n;
    reg         fall_en;
    reg         rise_en;
    reg         load;
    reg  [15:0] tx_data;
    reg         miso;
    reg         latch_rx;

    wire        mosi;
    wire [15:0] rx_data;

    // DUT
    spi_shift_reg dut (
        .sys_clk   (sys_clk),
        .sys_rst_n (sys_rst_n),
        .fall_en   (fall_en),
        .rise_en   (rise_en),
        .load      (load),
        .tx_data   (tx_data),
        .miso      (miso),
        .latch_rx  (latch_rx),
        .mosi      (mosi),
        .rx_data   (rx_data)
    );

    // 50 MHz clock => 20 ns period
    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    integer i;
    reg [15:0] miso_word;

    initial begin
        // Initial values
        sys_rst_n = 1'b0;
        fall_en   = 1'b0;
        rise_en   = 1'b0;
        load      = 1'b0;
        tx_data   = 16'hA5C3;
        miso      = 1'b0;
        latch_rx  = 1'b0;

        // Expected received word from MISO
        miso_word = 16'h3D92;

        // Hold reset for a few clocks
        repeat (3) @(posedge sys_clk);
        sys_rst_n = 1'b1;

        // Load TX data
        @(posedge sys_clk);
        load = 1'b1;
        @(posedge sys_clk);
        load = 1'b0;

        // Simulate 16 SPI bit transfers
        for (i = 15; i >= 0; i = i - 1) begin
            // Falling edge event: shift out next MOSI bit
            @(posedge sys_clk);
            fall_en = 1'b1;

            @(posedge sys_clk);
            fall_en = 1'b0;

            // Set MISO before the rising-edge sample
            miso = miso_word[i];

            // Rising edge event: sample MISO into RX shift reg
            @(posedge sys_clk);
            rise_en = 1'b1;

            @(posedge sys_clk);
            rise_en = 1'b0;
        end

        // Latch received word
        @(posedge sys_clk);
        latch_rx = 1'b1;

        @(posedge sys_clk);
        latch_rx = 1'b0;

        // Wait one more clock and print results
        @(posedge sys_clk);
        $display("--------------------------------------------------");
        $display("TX data sent     = 0x%h", tx_data);
        $display("Expected RX data = 0x%h", miso_word);
        $display("Actual RX data   = 0x%h", rx_data);
        $display("--------------------------------------------------");

        if (rx_data == miso_word)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        $finish;
    end

    // Helpful monitor
    initial begin
        $display("time\treset\tload\tfall_en\trise_en\tmiso\tmosi\trx_data");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%h",
                 $time, sys_rst_n, load, fall_en, rise_en, miso, mosi, rx_data);
    end

endmodule