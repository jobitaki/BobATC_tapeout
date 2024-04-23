`default_nettype none

module baud_rate_generator
  #(parameter CLK_HZ      = 25_000_000,
              BAUD_RATE   = 9600,
              SAMPLE_RATE = 16)
  (input  logic clock, reset_n,
   input  logic start_rx,
   input  logic start_tx,
   output logic tick);

  parameter DIVISOR = CLK_HZ / (BAUD_RATE * SAMPLE_RATE);

  logic [$clog2(DIVISOR) + 1:0] clockCount;

  assign tick = clockCount == DIVISOR;

  always_ff @(posedge clock, negedge reset_n)
    if (~reset_n | tick)
      clockCount <= '0;
    else if (start_rx)
      clockCount <= DIVISOR / 2;
    else if (start_tx)
      clockCount <= '0;
    else
      clockCount <= clockCount + 1'b1;

endmodule : baud_rate_generator