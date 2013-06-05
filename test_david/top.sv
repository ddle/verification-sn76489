


`include "scoreboard.sv"
`include "interface.sv"
`include "stimulus.sv"

module top();

	reg clk;
	int test1; 

	intf_sn76489 intf(clk);

	scoreboard sb = new;
	stimulus_sn76489 stim = new(intf, sb);

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
	forever #10 clk = ~clk;
	end

	always @ (posedge clk) 
  begin
//		$monitor ("%d \t %d \t %d \t %d", intf.tone1_out_o, intf.tone2_out_o, intf.tone3_out_o, intf.noise_out_o);
		$monitor ("%d \t %d \t %d \t %d \t %d \t %d", $time, intf.ready_o, intf.d_i, intf.we_n_i, intf.ce_n_i, intf.res_n_i);
	end

initial begin
	//sb.abc();
//	stim.test_1;
	stim.init;
intf.res_n_i = 0;
#100
intf.res_n_i = 1;
#50	intf.we_n_i=1;
	intf.ce_n_i=0;
	#50 stim.command_byte(2, 13);
	test1 = sb.is_checked(1); $display("test1, %d", test1);
  test1 = sb.check_frequency(1,1); 		$display("testa, %d", test1);
  test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);
  test1 = sb.check_frequency(1,5);		$display("testc, %d", test1);
	test1 = 100; $display("testc, %d", test1);
	sb.set_frequency(1,100);
  test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);
  test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);

	#10000000 $stop;
end


	
endmodule

