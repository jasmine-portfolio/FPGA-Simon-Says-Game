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
// File: main.sv
// Description: Simon Says Game (Lab Project)
// Author: Jasmine and Jimmy
// Date: 2024-04-04

/*
 * Game instructions:
 * 1. A pattern is displayed on an 8x8 LED matrix, with the number of blinks equal to the level number (e.g., Level 1 has 1 blink).
 * 2. A short tone plays after the pattern.
 * 3. The user recreates the pattern using the joystick to move and a push button to confirm the LED location.
 * 4. Incorrect responses trigger a high-pitched sound, and the user repeats the level.
 * 5. Correct responses trigger a low-pitched sound, and the user progresses to the next level.
 * 6. A 7-segment LED displays the current level and a countdown timer.
 * 
 * Features:
 * - 8x8 LED matrix for patterns
 * - Joystick and push button for user input
 * - 7-segment display for level and countdown
 * - Tone feedback for correct/incorrect answers
 * 
 * Notes:
 * - Difficulty increases with each level, showing more complex patterns.
 * - The sound and display give feedback on user progress.
 */


module main (
    input logic CLOCK_50,       // 50 MHz clock
    (* altera_attribute = "-name WEAK_PULL_UP_RESISTOR ON" *) 
    output logic [7:0] leds,    // 7-segment LED outputs
    output logic [3:0] ct,      // 7-segment LED control
    input logic s1, s2,         // Buttons for select and reset
    input logic ADC_SDO,        // ADC Serial Data Output
    output logic spkr,          // Speaker output
    output logic ADC_CONVST,    // ADC Conversion Start
    output logic ADC_SCK,       // ADC Serial Clock
    output logic ADC_SDI,       // ADC Serial Data Input
    output logic matrix_CLK,    // Matrix LED Clock
    output logic matrix_DIN,    // Matrix LED Data Input
    output logic matrix_CS,     // Matrix LED Chip Select
    output logic red, green, blue // RGB LEDs
);

///////////////////////////////////////
/////// Variable Declarations ////////
///////////////////////////////////////

// Clock
logic [1:0] digit;             // Select digit to display
logic [3:0] display_digit;     // Current digit of count to display
logic [15:0] clk_div_count;    // Counter to divide clock

// Matrix LED
logic [127:0] led_on = 0;      // Matrix LED - current LEDs that are on
logic [127:0] led_user = 0;    // Matrix LED - user LED pattern
logic [127:0] level_pattern = 0;  // Matrix LED - game level pattern
logic [3:0] level = 1;         // Level selector for LED pattern
logic [3:0] row = 0, col = 0;  // Matrix row and column positions
logic select = 0;              // Button s2 for LED selection
logic [3:0] level_user = 1;    // Track user game level
logic reset_move = 0;          // Flag to reset user LED pattern
logic remove_cursor = 0;       // Flag to remove cursor from LED

// Speaker
logic winLose = 0;             // Flag to select win (1) or lose (0) tone
logic [31:0] freq;             // Frequency for the speaker tone
logic play = 0;                // Control speaker on/off
logic win = 0;                 // Flag when user wins or loses

// ADC (Joystick)
logic [2:0] adc_chan = 0;      // ADC Channel
logic [11:0] result = 0;       // ADC result
logic up = 0, down = 0, left = 0, right = 0; // Joystick movement indicators
logic chan_select = 0;         // Channel selection for joystick

// Count time
logic [31:0] mainCount = 0;    // Overall game counter
logic [7:0] playTime = 14;     // Countdown timer for play time (7-segment display)
logic [31:0] game_count = 0;   // Game counter for time (1-second increments)
logic [31:0] finish_time = 1_106_247_680;  // Flag to check if the user finished the game before time ends

////////////////////////////////////////////////////
////// Instantiate Modules for Design Implementation////
///////////////////////////////////////////////////

// 7-segment LED modules
led_select_decoder led_select_decoder_0 (.digit(digit), .ct(ct));
led_number_decoder led_number_decoder_0 (.num(display_digit), .leds(leds));

// Speaker module
generate_tone #(.FCLK(50_000_000)) generate_tone_0 (.freq(freq), .spkr(spkr), .clk(CLOCK_50));
music music_play (.freq(freq), .reset_n(s1), .clk(CLOCK_50), .winLose(winLose), .play(play));

// Joystick ADC modules
adc_sample adc_sample_0 (.clk(clk_div_count[4]), .chan(adc_chan), .result(result), .ADC_CONVST(ADC_CONVST), .ADC_SCK(ADC_SCK), .ADC_SDI(ADC_SDI), .ADC_SDO(ADC_SDO));
joystick_move joystick_move_0 (.clk(clk_div_count[4]), .chan(adc_chan), .up(up), .down(down), .left(left), .right(right), .result(result));

// Matrix LED modules
matrix_led_pattern matrix_led_pattern_0 (.clk(CLOCK_50), .level(level), .led_on(led_on), .led_user(led_user), .level_user(level_user), .level_pattern(level_pattern));
matrix_led matrix_led_0 (.clk(clk_div_count[4]), .matrix_CLK(matrix_CLK), .matrix_DIN(matrix_DIN), .matrix_CS(matrix_CS), .led_on(led_on));
matrix_led_move matrix_led_move_0 (.clk(clk_div_count[4]), .led_user(led_user), .up(up), .down(down), .left(left), .right(right), .row(row), .col(col), .select(s2), .reset_move(reset_move), .remove_cursor(remove_cursor));

///////////////////////
/////// Code /////////
///////////////////////

// Clock divider to generate a 2-bit counter for digit selection
assign digit = clk_div_count[15:14]; 

// Turn off RGB LEDs by default
assign {red, green, blue} = '0;

always_ff @(posedge CLOCK_50) begin
    clk_div_count <= clk_div_count + 1'b1;  // Divide the clock for the digit selection

    // Display the pattern for user to memorize for 5 seconds
    if (mainCount >= 1 && mainCount <= 50 * 5_242_880) begin
        level <= level_user;  // Select level pattern based on user level
        play <= 0;            // Turn off speaker
        reset_move <= 0;      // Clear the user-selected LEDs
        finish_time <= 1_106_247_680;
    end

    // Play a short tone to notify the user it’s time to play (0.4s)
    if (mainCount >= 51 * 5_242_880 && mainCount <= 55 * 5_242_880) begin
        level <= 0;          // Clear the LED matrix
        winLose <= 1;        // Play the win tone
        play <= 1;           // Turn on speaker
    end

    // User has 15 seconds to match the pattern (14 seconds countdown)
    if (mainCount > 55 * 5_242_880 && mainCount < 205 * 5_242_880) begin
        game_count <= game_count + 1;  // Increment game counter each second
        if (game_count >= 5_242_880 * 10) begin
            playTime <= playTime - 1;  // Countdown for 14 seconds
            game_count <= 0;
        end
        level <= 9;  // Allow user to control the LED
        play <= 0;   // Turn off the speaker
    end

    // Remove cursor after 203 seconds
    if (mainCount == 203 * 5_242_880) begin
        remove_cursor <= 1;
    end

    // Check if the pattern matches
    if (mainCount > 55 * 5_242_880 && mainCount < 206 * 5_242_880 && led_user == level_pattern && level_user < 9 && win == 0) begin
        level_user <= level_user + 1;  // Move to the next level
        finish_time <= mainCount + 10 * 5_242_880;  // Reset time on 7-segment LED
        win <= 1;
    end

    // Play a tone to indicate user won for 1 second
    if (win == 1) begin
        winLose <= 1;   // Set tone to win
        play <= 1;      // Turn on the tone
        win <= 0;
        game_count <= 0;
        playTime <= 14; // Reset timer
        reset_move <= 1;
    end

    // Play a tone to indicate user lost for 1 second
    if (mainCount >= 206 * 5_242_880 && mainCount <= 215 * 5_242_880) begin
        game_count <= 0;
        playTime <= 14;  // Reset timer
        reset_move <= 1;

        if (win == 0) begin
            winLose <= 0;  // Set tone to lose
            play <= 1;     // Turn on the tone
        end
    end

    // Reset the game for the next level
    if (mainCount >= finish_time) begin
        level <= 0;
        play <= 0;      // Turn off tone
        remove_cursor <= 0;
        winLose <= 0;
        reset_move <= 1;  // Remove all user-selected LEDs
        if (level_user == 9) begin
            level_user <= 1;  // Reset level
        end
        mainCount <= 0;   // Reset main counter
        finish_time <= 1_106_247_680;
    end

    mainCount <= mainCount + 1;  // Increment main counter
end

// Display digit selection based on 'digit' value
always_comb begin
    case (digit)
        0 : display_digit = level_user;  // Display current level
        1 : display_digit = 15;          // Display 'L' for level
        2 : display_digit = playTime[3:0];  // Display time (lower nibble)
        3 : display_digit = playTime[7:4];  // Display time (upper nibble)
    endcase
end

endmodule
