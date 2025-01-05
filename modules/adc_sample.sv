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
// File: adc_sample.sv
// Description: Continually sample the ADC channel indicated by the module input port chan, and output the result on the output port result
// Author: Jimmy and Jasmine
// Date: 2024-04-04

module adc_sample(
    input logic clk,                // clock signal
    input logic [2:0] chan,         // ADC channel to sample (3-bit channel selector)
    input logic ADC_SDO,            // ADC Serial Data Output (SDO)
    output logic ADC_CONVST,        // ADC Convert Start signal
    output logic ADC_SCK,           // ADC Serial Clock (SCK)
    output logic ADC_SDI,           // ADC Serial Data Input (SDI)
    output logic [11:0] result      // ADC result (12-bit output)
);

    // Internal signals
    logic [15:0] ADCconfig = 15'h2200;  // ADC configuration register (16-bit)
    logic [4:0] count = 0;               // Counter to track sampling states
    logic state = 0;                     // State machine state (0 or 1)
    logic [2:0] chan2 = 0;              // Temporary variable to store channel
    logic skip = 0;                      // Skip flag to alternate channels
    logic working = 0;                   // Working state, unused in this snippet

    // Assign the Serial Clock based on the state
    assign ADC_SCK = (state) ? clk : 1'b0;

    // Always block to compute output based on clock's negative edge
    always_ff @(negedge clk) begin
        // When count reaches 0, reset ADC_CONVST and initialize the configuration
        if(count == 0) begin
            ADC_CONVST <= 1;           // Start the conversion
            state <= 0;                // Set state to idle
            ADC_SDI <= 0;              // Set SDI to 0
            ADCconfig <= {1'b1, chan[0], chan[2:1], 1'b1, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0};  // Set ADC config based on channel
        end else begin
            ADC_CONVST <= 0;          // Hold conversion signal low after start
        end
        
        // When count reaches 2, alternate the channel if skip flag is set
        if (count == 2) begin
            if (skip) chan2 <= chan2 + 1;  // Increment the temporary channel counter
            state <= 1;                     // Set state to active
        end
        
        // Set the ADC data input (SDI) based on ADC configuration
        if (count > 1 && count < 8) begin
            ADC_SDI <= ADCconfig[11 - count];  // Set SDI bit based on ADC configuration register
        end else begin
            ADC_SDI <= 0;               // Set SDI to 0 when not in the sampling range
        end
        
        // Increment counter, and reset after 13 counts
        count <= count + 1;
        if(count > 13) begin
            skip <= ~skip;           // Toggle the skip flag to alternate channel
            count <= 0;               // Reset the counter
            state <= 0;               // Set state back to idle
        end
    end

    // Always block to compute the ADC result on positive clock edge
    always_ff @(posedge clk) begin
        // Reset result at the beginning of a new sampling period
        if (count == 2) begin
            result <= 0;  // Clear the result when count reaches 2 (start of new sample)
        end
        
        // Capture ADC data bits after the 2nd count
        if (count < 15 && count > 2) begin
            result[14 - count] <= ADC_SDO;  // Store received data bits in the result register
        end
    end

endmodule
