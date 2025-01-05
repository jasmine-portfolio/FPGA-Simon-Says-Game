/*
 * MIT License
 * 
 * Copyright (c) 2025 jasmine-portfolio
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
// File: matrix_led.sv
// Description: 
// - Step up/initialization to turn on the matrix led
// - Generate Clock and MOSI signal for SPI LED controller
// Author: Jasmine
// Date: 2024-04-04

module matrix_led(
    input logic clk,                  // Clock signal
    input logic [127:0] led_on,       // 128-bit input for the LED pattern to be displayed
    output logic matrix_DIN,           // SPI Data Input for the LED matrix
    output logic matrix_CLK,           // SPI Clock for the LED matrix
    output logic matrix_CS             // SPI Chip Select for the LED matrix
);

    // Internal signals
    logic state = 0;                  // State variable to control the process flow
    logic dataout = 0;                // Data output signal
    logic addvalue = 1;               // Flag to determine if the counter should increment
    logic [4:0] bitcount = 0;         // Bit counter for the data transmission
    logic [6:0] indexcount = 0;       // Index counter to keep track of the data position in the pattern
    logic [127:0] led_previous = 0;   // Previous LED pattern, used to detect changes
    logic [239:0] init;               // Initialization data for the MAX7129 controller
    logic [63:0] count = 0;           // Counter to manage the cycle timing

    // Assign the matrix clock (SPI clock) based on the state
    assign matrix_CLK = (state) ? clk : 1'b0;

    // Always block triggered by the negative edge of the clock
    always_ff @(negedge clk) begin
        // Initialization step
        if (count == 0) begin
            state <= 0;                       // Set state to 0 (idle)
            matrix_CS <= 1;                   // Set chip select high (inactive)
            led_previous <= led_on;           // Save the current LED pattern
            indexcount <= 0;                  // Reset the index counter
            addvalue <= 1;                    // Set the addvalue flag to increment bitcount
            // Set up the initialization sequence for the MAX7129 controller and LED pattern
            init <= {8'h9, 8'h0, 8'hA, 8'h3, 8'hB, 8'h7, 8'hC, 8'h1, 8'hF, 8'h0, 8'h1, 8'hAA, 8'h2, 8'h55, led_on};
        end

        // Step to begin SPI data transmission
        if (count == 1) begin
            state <= 1;                       // Set state to 1 (transmitting)
            matrix_CS <= 0;                   // Set chip select low (active)
            dataout <= 1;                     // Prepare data for output
            bitcount <= 0;                    // Reset bit count
        end

        // SPI data transmission: shift out each bit of the initialization data
        if ((bitcount > 0) && (bitcount < 17)) begin
            matrix_DIN <= init[239 - (bitcount + indexcount * 16 - 1)]; // Output SPI data
            matrix_CS <= 0;                   // Keep chip select low (active)
            state <= 1;                       // Continue in transmission state
        end else begin
            matrix_CS <= 1;                   // Set chip select high (inactive) when not transmitting
            state <= 0;                       // Set state to idle
        end

        // Move to the next bit in the data sequence after 16 bits are transmitted
        if (bitcount == 17) begin
            indexcount <= indexcount + 1;     // Increment the index counter to move to the next data block
        end

        // After transmitting 16 bits, toggle chip select to indicate end of transmission block
        if (indexcount > 14) begin
            matrix_CS <= 1;                   // Set chip select high
            state <= 0;                       // Set state to idle
            addvalue <= 0;                    // Disable incrementing bitcount
        end

        // Increment bitcount if addvalue is set to 1
        bitcount <= bitcount + addvalue;

        // Start SPI clock for transmission when bitcount equals 1
        if (bitcount == 1) begin
            state <= 1;                       // Set state to transmitting
        end

        // If the LED pattern has changed, reset the count to retransmit the initialization sequence
        if (led_previous != led_on) begin
            count <= 0;                       // Reset the count to start from the beginning
        end else begin
            count <= count + 1;               // Otherwise, increment the count
        end
    end

endmodule
