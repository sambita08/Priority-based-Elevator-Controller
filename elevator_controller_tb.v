
`timescale 1ns/1ps
module tb_lift_controller_adv;
 // -----------------------------
 // TB Signals
 // -----------------------------
 reg clk;
 reg reset;
 reg [3:0] floor_req;
 reg emergency_stop;
 wire c_up;
 wire c_down;
 wire motor_stop;
 wire [1:0] current_floor;
 // -----------------------------
 // DUT Instantiation
 // -----------------------------
 lift_controller dut (
 .clk (clk),
 .reset (reset),
 .floor_req (floor_req),
 .emergency_stop(emergency_stop),
 .c_up (c_up),
 .c_down (c_down),
 .motor_stop (motor_stop),
 .current_floor (current_floor)
 );
 // -----------------------------
 // Clock Generation (10ns period)
 // -----------------------------
 always #5 clk = ~clk;
 // -----------------------------
 // Test Sequence
 // -----------------------------
 initial begin
 // Initialize
 clk = 0;
 reset = 1;
 floor_req = 4'b0000; 
 emergency_stop = 0;
 // Apply reset
 #20;
 reset = 0;
 // -----------------------------
 // Request Floor 2 (Move UP)
 // -----------------------------
 #10;
 floor_req = 4'b0100; // request floor 2
 #40;
 floor_req = 4'b0000; // clear request
 // -----------------------------
 // Request Floor 0 (Move DOWN)
 // -----------------------------
 #20;
 floor_req = 4'b0001; // request floor 0
 #40;
 floor_req = 4'b0000;
 // -----------------------------
 // Multiple Requests (Priority)
 // Floor 1 & 3 → Floor 1 has priority
 // -----------------------------
 #20;
 floor_req = 4'b1010;
 #40;
 floor_req = 4'b0000;
 // -----------------------------
 // Emergency Stop
 // -----------------------------
 #20;
 emergency_stop = 1;
 #30;
 emergency_stop = 0;
 // -----------------------------
 // End Simulation
 // -----------------------------
 #50;
 $finish;
 end
 // -----------------------------
 // Monitor
 // -----------------------------
 initial begin
 $monitor(
 "Time=%0t | Floor=%0d | Req=%b | UP=%b DOWN=%b STOP=%b EMG=%b",
 $time, current_floor, floor_req,
 c_up, c_down, motor_stop, emergency_stop
 );
 end
endmodule
