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
// File: matrix_led_move.sv
// Description: Based on the movement of the joystick (up, down, right and left), on led will moving on the matrix led
// Author: Jasmine
// Date: 2024-04-04

module matrix_led_move(
    output logic [127:0] led_user,  // Output for the LED pattern
    input logic clk,                 // Clock signal
    input logic up, down, left, right, select, reset_move, remove_cursor,  // Inputs for movement and control
    output logic [3:0] row, col      // Output for row and column positions
);

    // Initial LED matrix where all LEDs are turned off
    logic [127:0] internal_led = {8'h01, 8'h00, 8'h02, 8'h00, 8'h03, 8'h00, 8'h04, 8'h00, 
                                  8'h05, 8'h00, 8'h06, 8'h00, 8'h07, 8'h00, 8'h08, 8'h00};

    // Internal variables
    logic [15:0] counter = 0;
    logic [127:0] current_led = 0;
    logic [127:0] pressed_led = 0;
    logic up_previous = 0, down_previous = 0, left_previous = 0, right_previous = 0;

    // Always block that triggers on the rising edge of clock signal
    always_ff @(posedge clk) begin
        if (counter == 0) begin
            // Initialize the LED location at top-left corner (row = 7, col = 7)
            row <= 7;
            col <= 7;
        end

        counter <= counter + 1;

        if (counter == 15000) begin
            // Handle the movement of the LED based on the joystick buttons (up, down, left, right)
            if (col >= 1 && left == 0 && left_previous == 1) begin
                col <= col - 1;  // Move left
            end
            if (col < 7 && right == 0 && right_previous == 1) begin
                col <= col + 1;  // Move right
            end
            if (row >= 1 && down == 0 && down_previous == 1) begin
                row <= row - 1;  // Move down
            end
            if (row < 7 && up == 0 && up_previous == 1) begin
                row <= row + 1;  // Move up
            end

            current_led <= 0;  // Reset the current LED

            if (reset_move) begin
                // Clears the pressed LED to start the next level
                pressed_led <= 0;
            end

            // Update previous movement states
            up_previous <= up;
            down_previous <= down;
            left_previous <= left;
            right_previous <= right;
        end

        if (~select && counter < 15001) begin
            // Turn on the LED for both the pressed button and the joystick movement
            pressed_led <= pressed_led | current_led;
        end

        if (counter == 15001) begin
            // Update the current LED position based on joystick movement
            current_led[row*16 + col] <= 1;
        end

        if (counter == 15002) begin
            // Update the led_user pattern with or without the cursor to compare pressed pattern
            if (remove_cursor) begin
                led_user <= internal_led | pressed_led;  // Remove cursor
            end else begin
                led_user <= internal_led | current_led | pressed_led;  // Include cursor
            end
            counter <= 1;  // Reset counter
        end
    end

endmodule
