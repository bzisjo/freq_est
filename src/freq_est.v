module freq_est(
	input clk, RESETn,
	input stop,
	input signed [3:0] signal,
	output reg [9:0] counter_result
);

	reg last_sign;
	reg [9:0] counter;
	reg [10:0] 100uscounter;

	wire counter_rst;

	assign counter_rst = 100uscounter == 11'd1599;

	always @(posedge clk) begin
		if(~RESETn) begin
			last_sign <= 0;
			100uscounter <= 11'b0;
			counter <= 10'b0;
			counter_result <= 10'b0;
		end else begin
			last_sign <= signal[3];
			100uscounter <= counter_rst ? 11'b0 : 100uscounter + 1;
			counter <= (counter_rst | stop)		? 10'b0 :
					   last_sign ^ signal[3]	? counter + 1 :
					   							  counter;
			counter_result <= (counter_rst & !stop) ? counter : counter_result;
		end
	end

endmodule // freq_est