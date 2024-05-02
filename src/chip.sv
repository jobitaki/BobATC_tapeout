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
    .runway_override(io_in[2:1]),
    .emergency_override(io_in[3]),
    .tx(io_out[0]),
    .framing_error(io_out[1]),
    .runway_active(io_out[3:2]),
    .emergency(io_out[4]),
    .receiving(io_out[5]),
    .sending(io_out[6])
  );

endmodule
