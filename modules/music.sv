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
// File: music.sv
// Description: 
// - Tracks the number of clock pulses and converts each 4-count to 1 increment in the count variable.
// - Each value of count corresponds to a "note" (freq) to be played on a small speaker.  
// Author: Jimmy 
// Date: 2024-03-30

module music (
    output logic [31:0] freq,   // Output frequency for the music note
    input logic reset_n,        // Reset signal (active low)
    input logic clk,            // Clock signal
    input logic winLose,        // Indicator for win or lose condition
    input logic play            // Trigger for starting the music sequence
);
    
    // State enumeration for different music notes
    typedef enum logic [3:0] {
        IDLE,
        E4_NOTE,
        G4_NOTE,
        E5_NOTE,
        C5_NOTE,
        D5_NOTE,
        G5_NOTE,
        DS5_NOTE,
        D52_NOTE,
        CS5_NOTE
    } state_t;
    
    // Frequency values for the music notes
    parameter E4_FREQ = 330;
    parameter G4_FREQ = 392;
    parameter E5_FREQ = 659;
    parameter C5_FREQ = 523;
    parameter D5_FREQ = 587;
    parameter G5_FREQ = 784;
    parameter DS5_FREQ = 622;
    parameter D52_FREQ = 587;
    parameter CS5_FREQ = 554;
    
    // Counter for timing the duration of each note
    logic [23:0] counter;
    parameter COUNT_MAX = 7_500_000; // 150ms on a 50MHz clock
    
    // State variables for current and next state
    state_t state, next_state;
    
    // State transition on clock or reset
    always_ff @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            state <= IDLE;        // Reset to IDLE state
            counter <= 0;         // Reset the counter
        end else begin
            state <= next_state;  // Transition to the next state
            // Counter increment logic
            if (counter == COUNT_MAX - 1) begin
                counter <= 0;     // Reset counter
            end else begin
                counter <= counter + 1; // Increment counter
            end
        end
    end
    
    /*
        Music notes timing:
        Lose: Each note for 300ms
        - DS5 (622Hz)
        - D5 (587Hz)
        - CS5 (554Hz)

        Win: Each note for 150ms
        - E4 (330Hz)
        - G4 (392Hz)
        - E5 (659Hz)
        - C5 (523Hz)
        - D5 (587Hz)
        - G5 (784Hz)
    */
    
    // State machine logic for selecting the note and its frequency
    always_comb begin
        case(state)
            IDLE: begin
                freq = 0;  // No output frequency in IDLE state
                if (winLose && play) begin
                    next_state = E4_NOTE; // Start win music
                end else if (~winLose && play) begin
                    next_state = DS5_NOTE; // Start lose music
                end else begin
                    next_state = IDLE; // Stay in IDLE state
                end
            end
            
            E4_NOTE: begin
                freq = E4_FREQ;  // Set frequency to E4 (330Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = G4_NOTE; // Move to next note (G4)
                end else begin
                    next_state = E4_NOTE; // Stay in E4 note
                end
            end
            
            G4_NOTE: begin
                freq = G4_FREQ;  // Set frequency to G4 (392Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = E5_NOTE; // Move to next note (E5)
                end else begin
                    next_state = G4_NOTE; // Stay in G4 note
                end
            end
            
            E5_NOTE: begin
                freq = E5_FREQ;  // Set frequency to E5 (659Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = C5_NOTE; // Move to next note (C5)
                end else begin
                    next_state = E5_NOTE; // Stay in E5 note
                end
            end
            
            C5_NOTE: begin
                freq = C5_FREQ;  // Set frequency to C5 (523Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = D5_NOTE; // Move to next note (D5)
                end else begin
                    next_state = C5_NOTE; // Stay in C5 note
                end
            end
            
            D5_NOTE: begin
                freq = D5_FREQ;  // Set frequency to D5 (587Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = G5_NOTE; // Move to next note (G5)
                end else begin
                    next_state = D5_NOTE; // Stay in D5 note
                end
            end
            
            G5_NOTE: begin
                freq = G5_FREQ;  // Set frequency to G5 (784Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = IDLE; // Return to IDLE state after G5
                end else begin
                    next_state = G5_NOTE; // Stay in G5 note
                end
            end
            
            DS5_NOTE: begin
                freq = DS5_FREQ;  // Set frequency to DS5 (622Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = D52_NOTE; // Move to next note (D5)
                end else begin
                    next_state = DS5_NOTE; // Stay in DS5 note
                end
            end
            
            D52_NOTE: begin
                freq = D52_FREQ;  // Set frequency to D5 (587Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = CS5_NOTE; // Move to next note (CS5)
                end else begin
                    next_state = D52_NOTE; // Stay in D5 note
                end
            end
            
            CS5_NOTE: begin
                freq = CS5_FREQ;  // Set frequency to CS5 (554Hz)
                if (counter == COUNT_MAX - 1) begin
                    next_state = IDLE; // Return to IDLE state after CS5
                end else begin
                    next_state = CS5_NOTE; // Stay in CS5 note
                end
            end
            
            default: begin
                freq = 0;  // Default no frequency output
                next_state = IDLE; // Return to IDLE state
            end
        endcase
    end

endmodule

				
