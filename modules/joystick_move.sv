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
// File: joystick_move.sv
// Description: Gets the result from the adc by selecting chan 0 and 1 for X and Y value to output the location of the joystick up, down right or left, one at a time
// Author: Jimmy
// Date: 2024-04-04

module joystick_move(
    input logic clk,                 // Clock signal
    output logic [2:0] chan,         // Channel selector for ADC (3-bit output)
    input logic [11:0] result,       // Result from ADC (12-bit input)
    output logic up,                 // Up direction signal (for joystick movement)
    output logic down,               // Down direction signal (for joystick movement)
    output logic left,               // Left direction signal (for joystick movement)
    output logic right               // Right direction signal (for joystick movement)
);

    // Internal signals
    logic chan_select = 0;           // Temporary variable to store current channel selection (unused)
    logic [25:0] counter = 0;        // Counter to track time intervals for sampling and comparison

    // Always block triggered by positive edge of the clock
    always_ff @(posedge clk) begin
        counter <= counter + 1;      // Increment the counter on each clock cycle
        
        // When counter reaches 1, select channel 1 (Y-axis for joystick)
        if (counter == 1) begin
            chan <= 1;              // Set channel to 1 (Y-axis)
            down <= 0;              // Reset down signal
        end
        
        // When counter reaches 250, compare the ADC result for Y-axis (up or down)
        if (counter == 250) begin
            // If result is greater than a threshold, set up signal
            if (result > 'h950) begin
                up <= 1;           // Set up signal
                down <= 0;         // Reset down signal
            // If result is between certain thresholds, set down signal
            end else if (result < 'h3E8 && result > 'h50) begin
                up <= 0;           // Reset up signal
                down <= 1;         // Set down signal
            end else begin
                up <= 0;           // Reset up signal
                down <= 0;         // Reset down signal
            end
            chan <= 0;              // Switch to sample channel 0 (X-axis)
        end
        
        // When counter reaches 500, compare the ADC result for X-axis (left or right)
        if (counter == 500) begin
            // If result is greater than a threshold, set left signal
            if (result > 'h950) begin
                right <= 0;        // Reset right signal
                left <= 1;         // Set left signal
            // If result is between certain thresholds, set right signal
            end else if (result < 'h3E8 && result > 'h50) begin
                right <= 1;        // Set right signal
                left <= 0;         // Reset left signal
            end else begin
                right <= 0;        // Reset right signal
                left <= 0;         // Reset left signal
            end
            chan <= 1;              // Switch back to sample channel 1 (Y-axis)
            counter <= 0;           // Reset counter to start a new cycle
        end
    end

endmodule
