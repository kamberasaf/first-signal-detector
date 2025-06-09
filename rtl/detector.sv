`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: detector
// Project Name: First Signal Detector
// Description: Detects and locks onto the first signal(s) to arrive among
//              three input signals (a, b, c). Once detected, the output
//              is permanently locked and ignores future signal changes.
//
// Author: Asaf Kamber
// Create Date: 09/06/2025
//////////////////////////////////////////////////////////////////////////////////

module detector(
    input  logic clk,           // System clock
    input  logic rst,           // Active-low reset
    input  logic a, b, c,       // Input signals to monitor
    output logic [2:0] y        // Output: {c_detected, b_detected, a_detected}
);

    // Internal sticky enable signal
    logic en_stick;

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset: Clear enable and output
            en_stick <= 1'b0;
            y <= 3'b000;    
        end
        else begin
            // Update sticky enable - becomes high when any signal arrives
            // and stays high forever
            en_stick <= en_stick | a | b | c;
        
            // Update output only on first detection (when en_stick is still low)
            if (!en_stick) begin 
                y[0] <= a;  // Capture signal A
                y[1] <= b;  // Capture signal B  
                y[2] <= c;  // Capture signal C
            end
            // If en_stick is already high, y remains unchanged (locked)
        end
    end

endmodule