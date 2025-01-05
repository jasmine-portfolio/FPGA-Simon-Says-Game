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
// File: matrix_led_pattern.sv
// Description: Chooses the smile pattern of led for led_on based on the level
// Author: Jasmine
// Date: 2024-04-04

module matrix_led_pattern (
    input logic [3:0] level,        // Current level of the pattern
    input logic [3:0] level_user,   // User-defined level for custom LED pattern
    input logic clk,                // Clock signal
    input logic [127:0] led_user,   // User-defined 128-bit LED pattern
    output logic [127:0] led_on,    // LED pattern that will be displayed
    output logic [127:0] level_pattern // LED pattern for the user-defined level
);

    // Predefined LED smile patterns (8 different levels)
    logic [127:0] pattern1 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h20, 8'h04, 8'h00,
                              8'h05, 8'h00, 8'h06, 8'h00, 8'h07, 8'h00, 8'h08, 8'h00};   
    logic [127:0] pattern2 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h00, 8'h06, 8'h00, 8'h07, 8'h00, 8'h08, 8'h00};   
    logic [127:0] pattern3 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h40, 8'h06, 8'h00, 8'h07, 8'h00, 8'h08, 8'h00};   
    logic [127:0] pattern4 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h40, 8'h06, 8'h20, 8'h07, 8'h00, 8'h08, 8'h00};   
    logic [127:0] pattern5 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h40, 8'h06, 8'h20, 8'h07, 8'h10, 8'h08, 8'h00};   
    logic [127:0] pattern6 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h40, 8'h06, 8'h20, 8'h07, 8'h18, 8'h08, 8'h00};   
    logic [127:0] pattern7 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h40, 8'h06, 8'h24, 8'h07, 8'h18, 8'h08, 8'h00};   
    logic [127:0] pattern8 = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h24, 8'h04, 8'h00, 
                              8'h05, 8'h42, 8'h06, 8'h24, 8'h07, 8'h18, 8'h08, 8'h00};   
    logic [127:0] pattern_clear = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h00, 8'h04, 8'h00, 
                                  8'h05, 8'h00, 8'h06, 8'h00, 8'h07, 8'h00, 8'h08, 8'h00}; 

    // Always block triggered by the positive edge of the clock
    always @(posedge clk) begin
        // Case statement based on 'level' input to select the LED pattern to display
        unique case(level) 
            4'd0 : led_on <= pattern_clear; // Turn off all LEDs
            4'd1 : led_on <= pattern1;      // Display pattern 1
            4'd2 : led_on <= pattern2;      // Display pattern 2
            4'd3 : led_on <= pattern3;      // Display pattern 3
            4'd4 : led_on <= pattern4;      // Display pattern 4
            4'd5 : led_on <= pattern5;      // Display pattern 5
            4'd6 : led_on <= pattern6;      // Display pattern 6
            4'd7 : led_on <= pattern7;      // Display pattern 7
            4'd8 : led_on <= pattern8;      // Display pattern 8
            4'd9 : led_on <= led_user;      // Allow user to define the pattern
        endcase
        
        // Case statement based on 'level_user' to output the user pattern for the current level
        unique case(level_user)
            4'd1 : level_pattern <= pattern1;
            4'd2 : level_pattern <= pattern2;
            4'd3 : level_pattern <= pattern3;
            4'd4 : level_pattern <= pattern4;
            4'd5 : level_pattern <= pattern5;
            4'd6 : level_pattern <= pattern6;
            4'd7 : level_pattern <= pattern7;
            4'd8 : level_pattern <= pattern8;
            4'd9 : level_pattern <= pattern1; // Default to pattern 1
        endcase
    end

endmodule
