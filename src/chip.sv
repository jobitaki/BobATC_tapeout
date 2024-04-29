`default_nettype none

module my_chip (
    input logic [11:0] io_in, // Inputs to your chip
    output logic [11:0] io_out, // Outputs from your chip
    input logic clock,
    input logic reset // Important: Reset is ACTIVE-HIGH
);
    
  BobTop top(
    .clock(clock),
    .reset(reset),
    .rx(io_in[0]),
    .tx(io_out[0]),
    .framing_error(io_out[1]),
    .runway_active(io_out[3:2])
  );

endmodule
