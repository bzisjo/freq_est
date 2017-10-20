module freq_est(
	input clk, RESETn,
	input stop,
	input signed [3:0] signal,
	output reg valid,
	output reg [9:0] counter_result
);

	reg last_sign;
	reg [9:0] counter;
	reg [10:0] time_counter;

	wire counter_rst;
	wire counter_rst_posedge;
	wire stop_negedge;
	reg last_counter_rst;
	reg last_stop;


	assign counter_rst = time_counter == 11'd1599;

	assign counter_rst_posedge = counter_rst && !last_counter_rst;
	assign stop_negedge = !stop && last_stop;

	always @(posedge clk) begin
		if(~RESETn) begin
			last_sign <= 0;
			time_counter <= 11'b0;
			counter <= 10'b0;
			counter_result <= 10'b0;
			valid <= 0;
			last_stop <= 0;
		end else begin
			last_sign <= signal[3] & !stop;
			time_counter <= (counter_rst | stop) ? 11'b0 : time_counter + 1;
			counter <= (counter_rst | stop)		? 10'b0 :
					   last_sign ^ signal[3]	? counter + 1 :
					   							  counter;
			counter_result <= (counter_rst & !stop) ? counter : counter_result;
			last_counter_rst <= counter_rst;
			last_stop <= stop;
			valid <= stop_negedge ? 0 : (valid || counter_rst_posedge);
		end
	end

endmodule // freq_est