`default_nettype none
module uart_tx (
	clock,
	reset_n,
	send,
	data,
	tx,
	ready
);
	input wire clock;
	input wire reset_n;
	input wire send;
	input wire [8:0] data;
	output reg tx;
	output wire ready;
	wire start;
	wire tick;
	baud_rate_generator #(
		.CLK_HZ(25000000),
		.BAUD_RATE(9600),
		.SAMPLE_RATE(16)
	) conductor(
		.clock(clock),
		.reset_n(reset_n),
		.start_rx(1'b0),
		.start_tx(start),
		.tick(tick)
	);
	wire en_data_counter;
	reg [3:0] data_counter;
	wire done_data;
	wire clear_data_counter;
	assign done_data = data_counter == 4'd9;
	always @(posedge clock or negedge reset_n)
		if (!reset_n || clear_data_counter)
			data_counter <= 1'sb0;
		else if (en_data_counter && tick)
			data_counter <= data_counter + 1;
	reg [8:0] saved_data;
	reg data_bit;
	wire send_data;
	always @(posedge clock or negedge reset_n)
		if (!reset_n)
			saved_data <= 1'sb0;
		else if (start)
			saved_data <= data;
		else if (send_data && tick)
			saved_data <= saved_data >> 1;
	always @(posedge clock or negedge reset_n)
		if (!reset_n)
			data_bit <= 1'b0;
		else if (send_data && tick)
			data_bit <= saved_data[0];
	wire send_start_bit;
	wire send_stop_bit;
	always @(posedge clock or negedge reset_n)
		if (!reset_n)
			tx <= 1'b1;
		else if (send_start_bit)
			tx <= 1'b0;
		else if (send_data)
			tx <= data_bit;
		else if (send_stop_bit)
			tx <= 1'b1;
		else
			tx <= 1'b1;
	uart_tx_fsm fsm(
		.clock(clock),
		.reset_n(reset_n),
		.send(send),
		.tick(tick),
		.done_data(done_data),
		.start(start),
		.send_start_bit(send_start_bit),
		.send_data(send_data),
		.send_stop_bit(send_stop_bit),
		.en_data_counter(en_data_counter),
		.clear_data_counter(clear_data_counter),
		.ready(ready)
	);
endmodule
module uart_tx_fsm (
	clock,
	reset_n,
	send,
	tick,
	done_data,
	start,
	send_start_bit,
	send_data,
	send_stop_bit,
	en_data_counter,
	clear_data_counter,
	ready
);
	input wire clock;
	input wire reset_n;
	input wire send;
	input wire tick;
	input wire done_data;
	output reg start;
	output reg send_start_bit;
	output reg send_data;
	output reg send_stop_bit;
	output reg en_data_counter;
	output reg clear_data_counter;
	output reg ready;
	reg [1:0] state;
	reg [1:0] next_state;
	always @(*) begin
		start = 1'b0;
		send_start_bit = 1'b0;
		send_data = 1'b0;
		send_stop_bit = 1'b0;
		en_data_counter = 1'b0;
		clear_data_counter = 1'b0;
		ready = 1'b0;
		case (state)
			2'd0:
				if (send) begin
					next_state = 2'd1;
					start = 1'b1;
					send_start_bit = 1'b1;
				end
				else begin
					next_state = 2'd0;
					ready = 1'b1;
				end
			2'd1:
				if (tick) begin
					next_state = 2'd2;
					send_data = 1'b1;
					en_data_counter = 1'b1;
				end
				else begin
					next_state = 2'd1;
					send_start_bit = 1'b1;
				end
			2'd2:
				if (tick && done_data) begin
					next_state = 2'd3;
					send_stop_bit = 1'b1;
					clear_data_counter = 1'b1;
				end
				else begin
					next_state = 2'd2;
					send_data = 1'b1;
					en_data_counter = 1'b1;
				end
			2'd3:
				if (tick) begin
					next_state = 2'd0;
					ready = 1'b1;
				end
				else begin
					next_state = 2'd3;
					send_stop_bit = 1'b1;
				end
		endcase
	end
	always @(posedge clock or negedge reset_n)
		if (!reset_n)
			state <= 2'd0;
		else
			state <= next_state;
endmodule