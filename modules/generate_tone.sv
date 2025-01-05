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
// File: generate_tone.sv
// Description: generates an output at a specified frequency module generate_tone
// Author: Jimmy and Jasmine
// Date: 2024-04-04

module generate_tone
#( 
    parameter FCLK = 50_000_000  // Clock frequency (50 MHz by default)
)
(
    input logic [31:0] freq,     // Frequency to output on the speaker (input frequency value)
    output logic spkr,            // Speaker output signal
    input logic clk               // Clock signal (typically 50 MHz)
);

    // Internal signals
    logic [31:0] counter = 0;     // Counter to track the pulse duration for tone generation
    logic status = 0;             // Temporary variable to hold on/off status of tone
    logic temp = 0;               // Temporary flag, unused in current code
    logic test = 0;               // Test flag, unused in current code

    // Always block triggered by positive edge of the clock
    always_ff @(posedge clk) begin 
        // Increment the counter by (freq << 1), effectively multiplying freq by 2
        counter <= counter + (freq << 1); 

        // Check if counter exceeds the clock frequency (FCLK)
        if(counter >= FCLK) begin
            counter <= (freq << 1);  // Reset counter after reaching the clock frequency threshold
        end
    end

endmodule
