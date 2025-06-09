```systemverilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Interface Name: detector_if
// Description: SystemVerilog interface for detector module testbench
//////////////////////////////////////////////////////////////////////////////////

interface detector_if;
    logic clk;          // System clock
    logic rst;          // Active-low reset
    logic a, b, c;      // Input signals
    logic [2:0] y;      // Output signals
endinterface
```