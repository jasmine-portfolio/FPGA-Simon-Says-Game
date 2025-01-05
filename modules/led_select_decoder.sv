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
// File: led_select_decoder.sv
// Description: Select the location for 7-segment led
// Author: Jasmine
// Date: 2024-03-13

module led_select_decoder (
    input logic [1:0] digit,    // 2-bit input representing the digit (0-3)
    output logic [3:0] ct       // 4-bit output controlling the LED selection
);

    // Always block for combinatorial logic
    always_comb begin
        // Select the appropriate 4-bit LED control pattern based on the input digit
        case (digit)
            2'b00 : ct = 4'b1110;  // Far right LED is selected
            2'b01 : ct = 4'b1101;  // Second LED from the right is selected
            2'b10 : ct = 4'b1011;  // Second LED from the left is selected
            2'b11 : ct = 4'b0111;  // Far left LED is selected
        endcase
    end

endmodule
