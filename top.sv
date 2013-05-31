module top();

	reg clk;

	intf_sn76489 intf(clk);

	sn76489_top DUV (
		.clock_i(clk),
		.clock_en_i(intf.clock_en_i),
		.res_n_i(intf.res_n_i),
		.ce_n_i(intf.ce_n_i),
		.we_n_i(intf.we_n_i),
		.ready_o(intf.ready_o),
		.d_i(intf.d_i),
		.aout_o(intf.aout_o)
	);
	
	assign intf.tone1_out_o = DUV.tone1_s;
	assign intf.tone2_out_o = DUV.tone2_s;
	assign intf.tone3_out_o = DUV.tone3_s;
	assign intf.noise_out_o = DUV.noise_s;
 

	initial  begin// clock generator
	clk = 0;
	forever #50 clk = ~clk;
	end

	always @ (posedge clk) 
  begin
		$monitor ("%d \t %d \t %d \t %d", intf.tone1_out_o, intf.tone2_out_o, intf.tone3_out_o, intf.noise_out_o);
  end

initial begin
	#100000 $stop;
end


	
endmodule

