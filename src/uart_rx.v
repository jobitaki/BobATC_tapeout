`default_nettype none
module uart_rx (
	clock,
	reset,
	rx,
	data,
	done,
	framing_error
);
	input wire clock;
	input wire reset;
	input wire rx;
	output reg [8:0] data;
	output wire done;
	output wire framing_error;
	wire start;
	wire tick;
	baud_rate_generator #(
		.CLK_HZ(25000000),
		.BAUD_RATE(9600),
		.SAMPLE_RATE(16)
	) conductor(
		.clock(clock),
		.reset(reset),
		.start_rx(start),
		.start_tx(1'b0),
		.tick(tick)
	);
	wire collect_data;
	wire en_data_counter;
	wire clear_data_counter;
	reg [3:0] data_counter;
	wire done_data;
	always @(posedge clock or posedge reset)
		if (reset)
			data <= 1'sb0;
		else if (collect_data && tick) begin
			data <= data >> 1;
			data[8] <= rx;
		end
	assign done_data = data_counter == 4'd9;
	always @(posedge clock or posedge reset)
		if (reset || clear_data_counter)
			data_counter <= 1'sb0;
		else if (en_data_counter && tick)
			data_counter <= data_counter + 1'b1;
	uart_rx_fsm fsm(
		.clock(clock),
		.reset(reset),
		.tick(tick),
		.rx(rx),
		.done_data(done_data),
		.start(start),
		.collect_data(collect_data),
		.en_data_counter(en_data_counter),
		.clear_data_counter(clear_data_counter),
		.framing_error(framing_error),
		.done(done)
	);
endmodule
module uart_rx_fsm (
	clock,
	reset,
	tick,
	rx,
	done_data,
	start,
	collect_data,
	en_data_counter,
	clear_data_counter,
	framing_error,
	done
);
	input wire clock;
	input wire reset;
	input wire tick;
	input wire rx;
	input wire done_data;
	output reg start;
	output reg collect_data;
	output reg en_data_counter;
	output reg clear_data_counter;
	output reg framing_error;
	output reg done;
	reg [1:0] state;
	reg [1:0] next_state;
	always @(*) begin
		start = 1'b0;
		collect_data = 1'b0;
		en_data_counter = 1'b0;
		clear_data_counter = 1'b0;
		framing_error = 1'b0;
		done = 1'b0;
		case (state)
			2'd0:
				if (!rx) begin
					next_state = 2'd1;
					start = 1'b1;
				end
				else
					next_state = 2'd0;
			2'd1:
				if (tick && rx)
					next_state = 2'd0;
				else if (tick && !rx)
					next_state = 2'd2;
				else
					next_state = 2'd1;
			2'd2:
				if (tick && !done_data) begin
					next_state = 2'd2;
					collect_data = 1'b1;
					en_data_counter = 1'b1;
				end
				else if (tick && done_data) begin
					if (!rx) begin
						next_state = 2'd3;
						framing_error = 1'b1;
					end
					else begin
						next_state = 2'd0;
						clear_data_counter = 1'b1;
						done = 1'b1;
					end
				end
			2'd3:
				if (tick && rx) begin
					next_state = 2'd0;
					clear_data_counter = 1'b1;
				end
				else if (tick && !rx) begin
					next_state = 2'd3;
					framing_error = 1'b1;
				end
		endcase
	end
	always @(posedge clock or posedge reset)
		if (reset)
			state <= 2'd0;
		else
			state <= next_state;
endmodule