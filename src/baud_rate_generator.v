`default_nettype none
module baud_rate_generator (
	clock,
	reset_n,
	start_rx,
	start_tx,
	tick
);
	parameter CLK_HZ = 25000000;
	parameter BAUD_RATE = 9600;
	parameter SAMPLE_RATE = 16;
	input wire clock;
	input wire reset_n;
	input wire start_rx;
	input wire start_tx;
	output wire tick;
	parameter DIVISOR = CLK_HZ / (BAUD_RATE * SAMPLE_RATE);
	reg [$clog2(DIVISOR) + 1:0] clockCount;
	assign tick = clockCount == DIVISOR;
	always @(posedge clock or negedge reset_n)
		if (~reset_n | tick)
			clockCount <= 1'sb0;
		else if (start_rx)
			clockCount <= DIVISOR / 2;
		else if (start_tx)
			clockCount <= 1'sb0;
		else
			clockCount <= clockCount + 1'b1;
endmodule