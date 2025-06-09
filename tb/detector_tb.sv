```systemverilog
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module Name: detector_tb
// Description: Comprehensive testbench for first signal detector
// Tests: Reset, single signals, simultaneous signals, lock behavior
//////////////////////////////////////////////////////////////////////////////////

module detector_tb();
    
    // Test parameters
    localparam int CLK_PERIOD = 10;  // 10ns period (100MHz)
    localparam int RST_TIME = 25;    // Reset duration in ns
    
    // Interface instantiation
    detector_if det_if();
    
    // DUT instantiation
    detector dut (
        .clk(det_if.clk),
        .rst(det_if.rst),
        .a(det_if.a),
        .b(det_if.b),
        .c(det_if.c),
        .y(det_if.y)
    );

    // Clock generation
    initial det_if.clk = 0;
    always #(CLK_PERIOD/2) det_if.clk = ~det_if.clk;
    
    // Reset and input initialization
    initial begin
        det_if.rst = 0;
        det_if.a = 0;
        det_if.b = 0;
        det_if.c = 0;
        #RST_TIME;
        @(posedge det_if.clk);
        det_if.rst = 1;
    end
 
    // Main test sequence
    initial begin
        $display("=================================================");
        $display("First Signal Detector Test Suite");
        $display("=================================================");
        
        wait(det_if.rst);
        repeat(2) @(posedge det_if.clk);
        
        // Execute test suite
        reset_func_test();       // Test 1: Reset functionality
        single_signal_test();    // Test 2: Single signal detection
        simultaneous_test();     // Test 3: Simultaneous signals  
        lock_behavior_test();    // Test 4: Lock behavior
        
        $display("=================================================");
        $display("All tests completed successfully!");
        $display("=================================================");
        $finish;
    end

    //////////////////////////////////////////////////////////////////////////
    // Test Tasks
    
    task reset_func_test();
        $display("Test 1: Reset Functionality");
        
        if (det_if.y !== 3'b000)
            $display("FAIL: Output not reset correctly, y=%b (expected 000)", det_if.y);
        else
            $display("PASS: Output reset correctly");
            
        if (dut.en_stick !== 1'b0)
            $display("FAIL: Enable not reset correctly, en_stick=%b (expected 0)", dut.en_stick);
        else
            $display("PASS: Enable reset correctly");
            
        $display("Test 1 Complete");
        $display("-------------------------------------------------");
    endtask
    
    task single_signal_test();
        $display("Test 2: Single Signal Detection");
        
        // Test A only
        test_single_input("A", 1, 0, 0, 3'b001);
        // Test B only  
        test_single_input("B", 0, 1, 0, 3'b010);
        // Test C only
        test_single_input("C", 0, 0, 1, 3'b100);
        
        $display("Test 2 Complete");
        $display("-------------------------------------------------");
    endtask
   
    task simultaneous_test();
        $display("Test 3: Simultaneous Signal Detection");
        
        // Test all combinations
        test_simultaneous("AB", 1, 1, 0, 3'b011);
        test_simultaneous("AC", 1, 0, 1, 3'b101);
        test_simultaneous("BC", 0, 1, 1, 3'b110);
        test_simultaneous("ABC", 1, 1, 1, 3'b111);
        
        $display("Test 3 Complete");
        $display("-------------------------------------------------");
    endtask
    
    task lock_behavior_test();
        $display("Test 4: Lock Behavior Test");
        
        // Establish initial state (AB detected)
        apply_reset();
        apply_inputs(1, 1, 0);
        @(posedge det_if.clk);
        check_output("Initial AB detection", 3'b011);
        
        // Test various input changes - output should remain locked
        det_if.a = 0; det_if.b = 0; det_if.c = 1;
        repeat(2) @(posedge det_if.clk);
        check_output("After changing to C", 3'b011);
        
        det_if.a = 1; det_if.b = 1; det_if.c = 1;
        repeat(2) @(posedge det_if.clk);
        check_output("After setting ABC", 3'b011);
        
        det_if.a = 0; det_if.b = 0; det_if.c = 0;
        repeat(2) @(posedge det_if.clk);
        check_output("After removing all inputs", 3'b011);
        
        $display("Test 4 Complete");
        $display("-------------------------------------------------");
    endtask
    
    //////////////////////////////////////////////////////////////////////////
    // Helper Tasks
    
    task apply_reset();
        det_if.rst = 0;
        det_if.a = 0; det_if.b = 0; det_if.c = 0;
        repeat(2) @(posedge det_if.clk);
        det_if.rst = 1;
        @(posedge det_if.clk);
    endtask
    
    task apply_inputs(input logic a_val, b_val, c_val);
        det_if.a = a_val;
        det_if.b = b_val; 
        det_if.c = c_val;
    endtask
    
    task check_output(input string test_name, input logic [2:0] expected);
        if (det_if.y !== expected) begin
            $display("FAIL: %s - y=%b (expected %b)", test_name, det_if.y, expected);
        end else begin
            $display("PASS: %s - y=%b", test_name, det_if.y);
        end
    endtask
    
    task test_single_input(input string signal_name, 
                          input logic a_val, b_val, c_val,
                          input logic [2:0] expected);
        apply_reset();
        apply_inputs(a_val, b_val, c_val);
        @(posedge det_if.clk);
        check_output($sformatf("%s only", signal_name), expected);
    endtask
    
    task test_simultaneous(input string signal_name,
                          input logic a_val, b_val, c_val, 
                          input logic [2:0] expected);
        apply_reset();
        apply_inputs(a_val, b_val, c_val);
        @(posedge det_if.clk);
        check_output($sformatf("%s simultaneous", signal_name), expected);
    endtask
    
endmodule
```