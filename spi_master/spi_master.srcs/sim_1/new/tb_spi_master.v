//////////////////////////////////////////////////////////////////////////////////
// Company: CSUN
// Engineer: Keitaro Cho
// Create Date: 04/13/2026 12:05:55 PM
// Module Name: tb_spi_master
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns / 1ps

module tb_spi_master;

    reg         sys_clk;
    reg         sys_rst_n;
    reg         spi_en;
    reg  [7:0]  clk_div;
    reg         start;
    reg  [15:0] tx_data;
    reg         miso;

    wire        cs_n;
    wire        sclk;
    wire        mosi;
    wire [15:0] rx_data;
    wire        busy;
    wire        done;

    // DUT
    spi_master dut (
        .sys_clk (sys_clk),
        .sys_rst_n (sys_rst_n),
        .spi_en (spi_en),
        .clk_div (clk_div),
        .start (start),
        .tx_data (tx_data),
        .miso (miso),
        .cs_n (cs_n),
        .sclk (sclk),
        .mosi (mosi),
        .rx_data (rx_data),
        .busy (busy),
        .done (done)
    );

    // 50 MHz system clock -> 20 ns period
    initial begin
        sys_clk = 1'b0;
        forever #10 sys_clk = ~sys_clk;
    end

    reg [15:0] miso_word;
    integer i;

    initial begin
        // Initial values
        sys_rst_n  = 1'b0;
        spi_en     = 1'b0;
        clk_div    = 8'd3;       // small divider for faster sim
        start      = 1'b0;
        tx_data    = 16'hA5C3;
        miso       = 1'b0;
        miso_word  = 16'b00_1100_1010_0000_0;

        // Reset
        repeat (4) @(posedge sys_clk);
        sys_rst_n = 1'b1;

        // Enable SPI
        @(posedge sys_clk);
        spi_en = 1'b1;

        // Start transaction
        @(posedge sys_clk);
        start = 1'b1;
        @(posedge sys_clk);
        start = 1'b0;

        // Feed MISO bits MSB-first on each bit transfer
        // Set MISO before each rising sample edge
        
        for (i = 0; i >= 15; i = i + 1) begin
            @(negedge sclk);
            miso = miso_word[i];
        end
        
        // Wait for done
        wait(done == 1'b1);
        @(posedge sys_clk);
        
        // Start transaction
        @(posedge sys_clk);
        start = 1'b1;
        @(posedge sys_clk);
        start = 1'b0;

        // Feed MISO bits MSB-first on each bit transfer
        // Set MISO before each rising sample edge
        for (i = 15; i >= 0; i = i - 1) begin
            @(negedge sclk);
            miso = miso_word[i];
            if (i == 10) begin
                spi_en = 1'b0;
            end
        end

        // Wait for done
        wait(done == 1'b1);
        @(posedge sys_clk);

        $display("--------------------------------------------------");
        $display("TX data        = 0x%h", tx_data);
        $display("Expected RX    = 0x%h", miso_word);
        $display("Actual RX      = 0x%h", rx_data);
        $display("--------------------------------------------------");

        if (rx_data == miso_word)
            $display("TEST PASSED");
        else
            $display("TEST FAILED");

        repeat (5) @(posedge sys_clk);
        $finish;
    end

    // Monitor useful signals
    initial begin
        $display("time\treset\tstart\tcs_n\tsclk\tmosi\tmiso\tbusy\tdone\trx_data");
        $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%h",
                 $time, sys_rst_n, start, cs_n, sclk, mosi, miso, busy, done, rx_data);
    end

endmodule