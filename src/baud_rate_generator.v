`default_nettype none
module baud_rate_generator (
	clock,
	reset,
	start_rx,
	start_tx,
	tick
);
	parameter CLK_HZ = 25000000;
	parameter BAUD_RATE = 9600;
	parameter SAMPLE_RATE = 16;
	input wire clock;
	input wire reset;
	input wire start_rx;
	input wire start_tx;
	output wire tick;
	parameter DIVISOR = CLK_HZ / (BAUD_RATE * SAMPLE_RATE);
	reg [$clog2(DIVISOR) + 1:0] clockCount;
	assign tick = clockCount == DIVISOR;
	always @(posedge clock or posedge reset)
		if (reset | tick)
			clockCount <= 1'sb0;
		else if (start_rx)
			clockCount <= DIVISOR / 2;
		else if (start_tx)
			clockCount <= 1'sb0;
		else
			clockCount <= clockCount + 1'b1;
endmodule
module baud_rate_generator_tb;
	reg clock;
	reg reset;
	reg start_rx;
	wire start_tx;
	wire tick;
	baud_rate_generator dut(
		.clock(clock),
		.reset(reset),
		.start_rx(start_rx),
		.start_tx(start_tx),
		.tick(tick)
	);
	initial begin
		clock = 0;
		forever #(1) clock = ~clock;
	end
	initial $monitor("clockCount %b", dut.clockCount, , "tick %b", tick);
	initial begin
		start_rx = 0;
		reset <= 1'b1;
		@(posedge clock)
			;
		reset <= 1'b0;
		begin : sv2v_autoblock_1
			reg signed [31:0] i;
			for (i = 0; i < 1000; i = i + 1)
				@(posedge clock)
					;
		end
		start_rx <= 1'b1;
		@(posedge clock)
			;
		start_rx <= 1'b0;
		begin : sv2v_autoblock_2
			reg signed [31:0] i;
			for (i = 0; i < 1000; i = i + 1)
				@(posedge clock)
					;
		end
		$finish;
	end
endmodule