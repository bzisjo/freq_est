`timescale 1us / 10ps
module freq_est_testbench();

	localparam clk_period = 0.0625;
	localparam clk_period_half = 0.03125;

	integer sample_count;

	reg clk_16MHz, RESETn;
	reg stop;

	reg signed [3:0] signal;
	wire valid;
	wire [9:0] counter_result;

	reg [3:0] signal_thread [0:9999];

	always begin : clock_toggle_16MHz
		#(clk_period_half);
		clk_16MHz = ~clk_16MHz;
	end // clock_toggle_16MHz

	freq_est DUT(
		.clk           (clk_16MHz),
		.RESETn        (RESETn),
		.stop          (stop),
		.signal        (signal),
		.valid         (valid),
		.counter_result(counter_result)
	);


	initial begin : run_sim

		$readmemh("signal.dat", signal_thread);

		signal = signal_thread[0] - 4'd8;

		sample_count = 0;
		clk_16MHz = 1;
		RESETn = 0;
		stop = 0;
		#(clk_period);

		#(clk_period*7);
		RESETn = 1;
		#(clk_period);
		while (sample_count < 10000) begin
			signal = signal_thread[sample_count] - 4'd8;
			sample_count = sample_count + 1;
			#(clk_period);
			if(sample_count == 5000)
				stop = 1;
			if(sample_count == 5100)
				stop = 0;
		end // while (sample_count < 5000)
		stop = 1;

	end // run_sim

endmodule // freq_est_testbench