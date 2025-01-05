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
// File: led_number_decoder.sv
// Description: Select the value for 7-segment led
// Author: Jasmine
// Date: 2024-03-13

module led_number_decoder (
    input logic [3:0] num,    // 4-bit input number (0-15)
    output logic [7:0] leds   // 8-bit output controlling the 7-segment LEDs
);

    // Always block for combinatorial logic
    always_comb begin
        // Select the 7-segment LED pattern based on the input number (num)
        case (num)
            4'b0000 : leds = 8'b00111111;  // Display '0'
            4'b0001 : leds = 8'b00000110;  // Display '1'
            4'b0010 : leds = 8'b01011011;  // Display '2'
            4'b0011 : leds = 8'b01001111;  // Display '3'
            4'b0100 : leds = 8'b01100110;  // Display '4'
            4'b0101 : leds = 8'b01101101;  // Display '5'
            4'b0110 : leds = 8'b01111101;  // Display '6'
            4'b0111 : leds = 8'b00000111;  // Display '7'
            4'b1000 : leds = 8'b01111111;  // Display '8'
            4'b1001 : leds = 8'b01101111;  // Display '9'
            4'b1010 : leds = 8'b01110111;  // Display 'A'
            4'b1011 : leds = 8'b01111100;  // Display 'b' (lowercase 'b' for level indicator)
            4'b1100 : leds = 8'b00111001;  // Display 'C'
            4'b1101 : leds = 8'b01011110;  // Display 'd'
            4'b1110 : leds = 8'b01111001;  // Display 'E'
            4'b1111 : leds = 8'b00111000;  // Display 'L' (used for level)
            default : leds = 8'b11111110;  // Default: turn off all segments except for 'G'
        endcase
    end

endmodule
