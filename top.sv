
`include "scoreboard.sv"
`include "interface.sv"
`include "stimulus.sv"
`include "checker.sv"
`include "monitor.sv"

module top();

	reg clk;
	int test1; 

	intf_sn76489 intf(clk);

	scoreboard sb = new;
	stimulus_sn76489 stim = new(intf, sb);
	monitor mnt = new();
	checker_ check = new(intf,sb,mnt);

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
 
	freq_det det1( .clk(clk),			
				  .in_signal(DUV.tone1_s),		// signal to be detected	
				  .out_counter(intf.det_counter_out[0]),    // output counter value
				  .done(intf.det_done_out[0]),
				  .out_magnitude(intf.det_magnitude_out[0])
	);

	freq_det det2( .clk(clk),			
				  .in_signal(DUV.tone2_s),		// signal to be detected	
				  .out_counter(intf.det_counter_out[1]),    // output counter value
				  .done(intf.det_done_out[1]),
				  .out_magnitude(intf.det_magnitude_out[1])
	);

	freq_det det3( .clk(clk),			
				  .in_signal(DUV.tone3_s),		// signal to be detected	
				  .out_counter(intf.det_counter_out[2]),    // output counter value
				  .done(intf.det_done_out[2]),
				  .out_magnitude(intf.det_magnitude_out[2])
	);

	freq_det det4( .clk(clk),			
				  .in_signal(DUV.noise_s),		// signal to be detected	
				  .out_counter(intf.det_counter_out[3]),    // output counter value
				  .done(intf.det_done_out[3]),
				  .out_magnitude(intf.det_magnitude_out[3])
	);

	initial  begin// clock generator
	clk = 0;
	forever #10 clk = ~clk;
	end

	always @ (intf.ready_o, intf.d_i, intf.we_n_i, intf.ce_n_i, intf.res_n_i, intf.tone1_out_o, intf.tone2_out_o, intf.tone3_out_o, intf.noise_out_o, DUV.clk_en_s) 
  begin
//		$monitor ("%d \t %d \t %d \t %d", intf.tone1_out_o, intf.tone2_out_o, intf.tone3_out_o, intf.noise_out_o);
//		$display ("%d\t%d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d \t %d",$time, intf.ready_o, intf.d_i, intf.we_n_i, intf.ce_n_i, intf.res_n_i, intf.tone1_out_o, intf.tone2_out_o, intf.tone3_out_o, intf.noise_out_o, DUV.clk_en_s);
	end

	always @ (intf.det_done_out[0], sb.checked[0], sb.modified[0])
	begin
//		$display("%d\tgen %d\tdet_done %d\tchecked %d\tmodified %d",$time,0,intf.det_done_out[0], sb.checked[0], sb.modified[0]);
	end

	always @ (intf.det_done_out[1], sb.checked[1], sb.modified[1])
	begin
//		$display("%d\tgen %d\tdet_done %d\tchecked %d\tmodified %d",$time,1,intf.det_done_out[1], sb.checked[1], sb.modified[1]);
	end

	always @ (intf.det_done_out[2], sb.checked[2], sb.modified[2])
	begin
//		$display("%d\tgen %d\tdet_done %d\tchecked %d\tmodified %d",$time,2,intf.det_done_out[2], sb.checked[2], sb.modified[2]);
	end

	always @ (intf.det_done_out[3], sb.checked[3], sb.modified[3])
	begin
//		$display("%d\tgen %d\tdet_done %d\tchecked %d\tmodified %d",$time,3,intf.det_done_out[3], sb.checked[3], sb.modified[3]);
	end

	always @ (posedge intf.det_done_out[0])
	begin
//		$display("Tone Generator 1, Frequency %d\t Magnitude %d",intf.det_counter_out[0],intf.det_magnitude_out[0]);
	end

	always @ (posedge intf.det_done_out[1])
	begin
//		$display("Tone Generator 2, Frequency %d\t Magnitude %d",intf.det_counter_out[1],intf.det_magnitude_out[1]);
	end

	always @ (posedge intf.det_done_out[2])
	begin
//		$display("Tone Generator 3, Frequency %d\t Magnitude %d",intf.det_counter_out[2],intf.det_magnitude_out[2]);
	end

	always @ (posedge intf.det_done_out[3])
	begin
//		$display("Noise Generator, Frequency %d\t Magnitude %d",intf.det_counter_out[3],intf.det_magnitude_out[3]);
	end

function display_registers(); 
		$display("Tone1: freq\t%d\tatten\t%d",DUV.tone1_b.f_q, DUV.tone1_b.a_q);
		$display("Tone2: freq\t%d\tatten\t%d",DUV.tone2_b.f_q, DUV.tone2_b.a_q);
		$display("Tone3: freq\t%d\tatten\t%d",DUV.tone3_b.f_q, DUV.tone3_b.a_q);
		$display("Noise: freq\t%d\tatten\t%d",{DUV.noise_b.fb_q,DUV.noise_b.nf_q}, DUV.noise_b.a_q);
endfunction

initial begin
display_registers();
//	sb.abc();
// Begin test case 1.  
	stim.test_1;
// Begin test case 2.
	stim.test_2;

	stim.reset;

fork 
	check.check(0);
join_none
fork 
	check.check(1);
join_none
fork 
	check.check(2);
join_none
fork 
	check.check(3);
join_none

// Begin test case 3.
	$display("Begin Test Case 3");
	for (int i = 3; i < 8; i=i+2) 
	begin
		stim.write_register(i,4'b1111);	// set attenuation to off
	end
	for (int j = 0; j < 3; j++)
	begin
		stim.write_register((j*2)+1,4'b0000);	// set attenuation to off
		stim.write_register((j*2),10'b11_1111_1111);	// set frequency to maximum
		$display("Test Case 3.1.%d set...", j);	
		display_registers();
		for (int i = 0; i < 4; i++) @ (posedge intf.det_done_out[j]);
		stim.write_register((j*2),10'b1);	// set frequency to minimum
		$display("Test Case 3.2.%d set...",j);	
		display_registers();
		for (int i = 0; i < 4; i++) @ (posedge intf.det_done_out[j]);
		$display("Begin Test Case 3.3.%d set...",j);	
		for (int i = 1; i < 16; i++)
		begin
		stim.write_register((j*2)+1,i);	// step through attenuation values
		if (i < 15) for (int i = 0; i < 4; i++) @ (posedge intf.det_done_out[j]);
		end
	end
	$display("End Test Case 3");

	for (int i = 1; i < 8; i=i+2) 
	begin
		stim.write_register(i,4'b1);	// set attenuation to on.
	end

	$display("Start Test Case 5, Random Stimulation");
	repeat (500) begin
		stim.drive_random;
		display_registers;
	end
	$display("End Test Case 5");

	intf.end_of_test = 1;




//	test1 = sb.check_frequency(1,1); 		$display("testa, %d", test1);
//	test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);
//  test1 = sb.check_frequency(1,5);		$display("testc, %d", test1);
//	test1 = 100; $display("testc, %d", test1);
//	sb.set_frequency(1,100);
//	test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);
//  test1 = sb.check_frequency(1,100); 		$display("testb, %d", test1);
	$display($time);
	#15600000 $stop;
end


	
endmodule

