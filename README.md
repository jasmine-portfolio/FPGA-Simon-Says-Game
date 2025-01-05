# FPGA Simon Says Game with SystemVerilog

Welcome to the **Simon Says** game, implemented on an FPGA! This project brings the classic memory game to life using SystemVerilog and FPGA hardware. It features an 8x8 LED matrix, 7-segment LEDs, a joystick for user input, and sound feedback through a speaker, providing an engaging and interactive experience.

![simon-says-smile](https://github.com/user-attachments/assets/a1cbda20-df59-4361-9547-e6aa3b54a712)

## 🚀 **Game Instructions**

1. A pattern is displayed on an 8x8 LED matrix, with the number of blinks equal to the level number (e.g., Level 1 has 1 blink).
2. A short tone plays after the pattern.
3. The user recreates the pattern using the joystick to move and a push button to confirm the LED location.
4. Incorrect responses trigger a high-pitched sound, and the user repeats the level.
5. Correct responses trigger a low-pitched sound, and the user progresses to the next level.
6. A 7-segment LED displays the current level and a countdown timer.


## 🖱️ Hardware Requirements

- **8x8 LED Matrix** (MAX7219): Displays the patterns you need to memorize and your input selection.
- **7-Segment Display**: Shows the current game level and the countdown timer.
- **Joystick**: Allows you to select the LEDs on the matrix to match the pattern.
- **Buzzer**: Provides sound feedback to signal correct or incorrect answers.


## 🖥️ **Code Breakdown**

- **`main.sv`**: The main game logic, which controls the flow of the game and interaction with other modules.
- **Modules**:
    - **`adc_sample.sv`**: Samples the joystick data via ADC and converts it into usable input signals.
    - **`generate_tone.sv`**: Generates audio tones for feedback (e.g., high-pitched and low-pitched tones for correct/incorrect answers).
    - **`joystick_move.sv`**: Interprets the joystick input (up, down, left, right) to move through the LED matrix.
    - **`led_number_decoder.sv`**: Converts the game state into a readable format that is displayed on the 7-segment display.
    - **`matrix_led.sv`**: Controls the 8x8 LED matrix, lighting up LEDs based on the current pattern.
    - **`matrix_led_pattern.sv`**: Generates the LED smile pattern for each level of the game.
    - **`music.sv`**: Controls sound effects that play when you win or lose a level.

## 🔧 **Getting Started**
### 1. **Clone the Repository**
To get started, follow these simple steps:
- **Step 1**: Install Git (if not already installed) from [here](https://git-scm.com/downloads).
- **Step 2**: Clone the repository by running the following command in your terminal or command prompt:
    ```bash
    bash    git clone https://github.com/yourusername/simon-says-fpga.git
    ```
- **Step 3**: Connect the components to your FPGA board based on Hardware Setup Diagram.
- **Step 4**: Load the SystemVerilog code onto your FPGA board. This can typically be done using an FPGA programming tool (e.g., Vivado, Quartus, etc.).
- **Step 5**: Play and have fun!

### 2. **Alternative: Download as ZIP**

1. **Step 1**: Download the repository as a ZIP file.
2. **Step 2**: Extract the folder to your local machine.
3. **Step 3**:  Connect the components to your FPGA board based on Hardware Requirements.
4. **Step 4**: Load the code onto your FPGA and start enjoying the game!


## ✨ **Customization Tips**

- **Custom LED Patterns and Adjusting Difficulty**: You can modify the `matrix_led_pattern.sv` module to add custom LED patterns by directly controlling the rows and columns of the 8x8 matrix.
    - The pattern is defined by an 8-bit value for each row. The first 8-bit value selects the row, and the following 8-bit value determines which LEDs in that row are turned on (1) or off (0).
    - For example, to select row 1, use `8'h01`. For column 2 and 8, the value would be `8'h41` (binary `01000001`), which lights up row 1, column 2, and column 8.
    - Repeat this process for each row (up to row 8) to create complex LED patterns for different levels of the game.
- **Custom Sound Effects**: You can experiment with different audio frequencies and tones by modifying the `music.sv` module.
    - Inside the module, you can change the `state_t` enum, which controls the frequency pattern for the sound effects (win/lose sounds or level progression sounds).
    - Adding new states or adjusting existing ones can allow you to create custom sound effects for different game events.

## 📄 **License**

This project is licensed under the MIT License. Feel free to fork, modify, and use it for your own portfolio.
