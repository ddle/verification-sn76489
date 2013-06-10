`ifndef GUARD_STIM 
`define GUARD_STIM

`include "interface.sv"
`include "random.sv"
`include "coverage.sv"

// stimuls class for SN76489 Complex Sound Generator chip verification.

class stimulus_sn76489;

	rand_test_case		rnd = new(5);
	virtual intf_sn76489		intf;			// interface to DUV.
	scoreboard			sb;				// scoreboard
	
	sn_coverage cov;		

	function new(virtual intf_sn76489 intf,scoreboard sb);
		this.intf = intf;
		this.sb = sb;
		cov = new();
	endfunction

	task init(); 
		intf.ce_n_i = 0;
		intf.we_n_i = 1; 
		intf.d_i = 0; 
		@ (posedge intf.clk);	
	endtask

// test case 1.  Verify function of READY output according to table 5 of SN76489 datasheet.
	task test_1();
		// SN76489 Datasheet Table 5 is valid when:
		//		(1) device is not being clocked. 
		intf.clock_en_i = 0;
		//		(2) device is initialized by pulling n_we_i and n_ce_i both high. 
		intf.ce_n_i = 1;
		intf.we_n_i = 1; 	
		
		// run test cases 1.1 through 1.4 in different orders. 
		test_1_1();
		test_1_3();
		test_1_2();
		test_1_4();

		test_1_2();
		test_1_1();
		test_1_4();
		test_1_3();

	endtask
		
	task test_1_1();		
		// 1.1 Set CE and WE to 11, verify READY output is 1
		intf.ce_n_i = 1;
		intf.we_n_i = 1; 		
		@ (posedge intf.clk);		
		
		if (intf.ready_o == 0)
			$display("error on test case 1.1");
		else 
			$display("test case 1.1 passed");

	endtask

	task test_1_2();	
		// 1.2 Set CE and WE to 10, verify READY output is 1
		intf.ce_n_i = 1;
		intf.we_n_i = 0; 		

		@ (posedge intf.clk);
		if (intf.ready_o == 0)
			$display("error on test case 1.2");
		else 
			$display("test case 1.2 passed");

	endtask

	task test_1_3();	
		// 1.3 Set CE and WE to 01, verify READY output is 0
		intf.ce_n_i = 0;
		intf.we_n_i = 1; 		
		@ (posedge intf.clk);
		if (intf.ready_o == 1)
			$display("error on test case 1.3");
		else 
			$display("test case 1.3 passed");

	endtask

	task test_1_4();	
		// 1.4 Set CE and WE to 00, verify READY output is 0
		intf.ce_n_i = 0;
		intf.we_n_i = 0; 		
		@ (posedge intf.clk);
		
		if (intf.ready_o == 1)
			$display("error on test case 1.4");
		else 
			$display("test case 1.4 passed");

	endtask

 	// test case 2.  Verify function of ready_o when loading data on the data bus.
	task test_2();
		int start_time;
		int end_time;
		int write_time;

		$display("Starting test case 2");
		intf.ce_n_i = 1;
		intf.we_n_i = 1;
		reset();
		intf.ce_n_i = 0;
		intf.d_i = {1'b1,3'b001,4'b0001};  // place data on bus - Tone 1 Attenuation = 1;
		@ (posedge intf.clk); 
		intf.we_n_i = 0;
		if (intf.ready_o == 1) @ (negedge intf.ready_o);
			
		start_time = $time;
		@ (posedge intf.ready_o);
		end_time = $time;
		write_time = (end_time - start_time) / 20;
		if (write_time < 28 || write_time > 36) $display("Test case 2 failed,  # of clock cycles: %d", write_time);
		else $display("Test case 2 pass, # of clock cycles: %d", write_time);

		intf.ce_n_i = 1;
		intf.we_n_i = 1;		
		
	endtask

// command_byte() is used to initiate sending of a command byte.
// inputs:
//	int register - which register we are accessing. 
//			range: 0-7 	accesses the 8 registers using the register address
//						 8-15	accesses the latched register (the format is based on the 3
//								lower bits of the register value.
//	int data - the value to be placed in the register.
//			range depends on register selected, per datasheet. 

	task command_byte(int register, int data);
		bit [2:0] register_bits = register;
		bit [9:0] data_bits = data;
		$display("command byte - register: %d value: %d", register_bits, data_bits);

		// wait for DUV to be ready.
		if (intf.ready_o == 0)
			begin
				@ (posedge intf.ready_o); 
			end

		// verify clock enable is active (low)
		if (intf.ce_n_i == 1)
			begin
				intf.ce_n_i = 0;
			end

		
		if (intf.ce_n_i == 0)						// should always be true from above
			if (intf.we_n_i == 1) begin

				// define bus input based on register chosen.
				if (register == 0 || register == 2 || register == 4) begin
					// Tone generator frequency registers
					$display("tone generator register: %x value: %x", register_bits, data_bits);
					intf.d_i = {1'b1,register_bits,data_bits[3:0]};
				end
				else if (register == 6) begin
					// Noise source register
					intf.d_i = {1'b1,register_bits,1'b0,data_bits[2:0]};
				end
				else if (register == 1 || register == 3 || register == 5 || register == 7) begin
					// Attenuation register
					intf.d_i = {1'b1,register_bits,1'b0,data_bits[3:0]};
				end
				else if (register > 7) begin
					// use latched register.  (unused data bits will be ignored)
					if (register_bits == 0 || register_bits == 2 || register_bits == 4) begin
						// shift data_bits right 4 bits to access 6 upper bits.
						data_bits = data_bits >> 4;
					end
					intf.d_i = {1'b0,1'b0,data_bits[5:0]};	
				end

				// activate write enable and wait for ready to go high.
				//intf.we_n_i = 0;
				$display("write enable asserted low");
				
				if (intf.ready_o == 0) @ (posedge intf.ready_o);
				
				// if second byte is needed (frequency registers)
				if (register == 0 || register == 2 || register == 4) begin
					data_bits = data_bits >> 4;					
					$display("writing second command byte");
					intf.d_i = {1'b0,1'b0,data_bits[5:0]};	
					@ (posedge intf.ready_o);
				end
		
				$display("deactivating write_enable");
				//deactivate write enable after ready signal has gone high.
				intf.we_n_i = 1;

			end 
			else $display("Command failed due to we_n_i being asserted low");

	else $display("Command failed due to ce_n_i being asserted low");
	endtask			// command byte


	task drive_byte(int data);
		$display("drive_byte(%d) called",data);
		// set chip enable and write enable to 1 (inactive)
		intf.we_n_i = 1;
		intf.ce_n_i = 1;

		// assign data to d_i input.
		intf.d_i = data;

		@ (posedge intf.clk);
		// wait for ready to be high. 
		if (intf.ready_o == 0)
			begin
				@ (posedge intf.ready_o); 
			end		
	
		// set chip enable and write enable to 0 (active)
		intf.we_n_i = 0;
		intf.ce_n_i = 0;
	
		@ (posedge intf.ready_o); 
		// set chip enable and write enable to 1 (inactive)
		intf.we_n_i = 1;
		intf.ce_n_i = 1;

	endtask			// drive_byte

	task reset();
		intf.clock_en_i = 1;	
		intf.res_n_i = 0;
		#40	intf.res_n_i = 1;
	endtask

	task write_register(int register, int data, bit xval = 0);
		bit [2:0] register_bits = register;
		bit [9:0] data_bits = data;
		bit [7:0] command_byte,command_byte2;
		bit second_byte = 0;

		if (sb.checked[ register_bits[2:1] ] == 0)
			@ (posedge sb.checked[ register_bits[2:1] ] ); 

		$display("command byte - register: %d value: %d", register_bits, data_bits);

		if (register == 0 || register == 2 || register == 4) begin
			// Tone generator frequency registers
			command_byte = {1'b1,register_bits,data_bits[3:0]};
			command_byte2 = {1'b0,xval,data_bits[9:4]};
			second_byte = 1;
			$display("tone generator register - %d %d", command_byte, command_byte2);
		end
		else if (register == 6) begin
			// Noise source register
			command_byte = {1'b1,register_bits,xval,data_bits[2:0]};
			$display("noise source control register - %d", command_byte);
		end
		else if (register == 1 || register == 3 || register == 5 || register == 7) begin
			// Attenuation register
			command_byte = {1'b1,register_bits,data_bits[3:0]};
			$display("attenuation register - %d", command_byte);
		end
		else if (register > 7) begin
			$display("latched register");
			// use latched register.  (unused data bits will be ignored)
			if (register_bits == 0 || register_bits == 2 || register_bits == 4) begin
				// shift data_bits right 4 bits to access 6 upper bits.
				data_bits = data_bits >> 4;
			end
			command_byte = {1'b0,1'b1,data_bits[5:0]};	
		end

		sb.packet_number++;
		sb.modified[register_bits[2:1]][register_bits[0]] = 1;
		drive_byte(command_byte);
		if (register_bits[0] == 0 && register <= 7) begin 
			//sb.set_frequency(register_bits[2:1],data);
			sb.frequency[register_bits[2:1]] = data;
		end
		else if (register_bits[0] == 0 && register > 7) begin
			sb.frequency[register_bits[2:1]] = {data[9:4],sb.frequency[register_bits[2:1]][6:9]};
		end 
		else begin
			//sb.set_attenuation(register_bits[2:1],data);
			sb.attenuation[register_bits[2:1]] = data;
		end
//		if (sb.frequency[register_bits[2:1]] > 0 && sb.attenuation[register_bits[2:1]] < 15)
//				sb.checked[register_bits[2:1]] = 0;
		if (second_byte) begin
			drive_byte(command_byte2);
			
		cov.sample(sb);

		end
		fork
		@ (negedge intf.det_done_out[register_bits[2:1]])
		@ (negedge intf.det_done_out[register_bits[2:1]])
		sb.modified[register_bits[2:1]][register_bits[0]] = 0;		
		join_none

	endtask			// write_register

	
	task drive_random();
		int register_temp;
		rnd.randomize();
		register_temp = (rnd.register > 7) ? rnd.latched_reg[2:1] : rnd.register[2:1];
//	if (sb.checked[register_temp] == 0) @ (posedge sb.checked[register_temp]);
	
		if (sb.modified[register_temp] && sb.frequency[register_temp] > 0 && sb.attenuation[register_temp] < 15) 
		begin 
			$display("%d Waiting for generator %d to be evaluated",$time,register_temp);
			@ (posedge intf.det_done_out[register_temp]);
		end

		if (sb.modified[register_temp] && sb.frequency[register_temp] > 0 && sb.attenuation[register_temp] < 15) 
		begin 
			$display("%d Waiting for generator %d to be evaluated",$time,register_temp);
			@ (posedge intf.det_done_out[register_temp]);
		end

		if (sb.modified[register_temp] && sb.frequency[register_temp] > 0 && sb.attenuation[register_temp] < 15) 
		begin 
			$display("%d Waiting for generator %d to be evaluated",$time,register_temp);
			@ (posedge intf.det_done_out[register_temp]);
		end
		
		$display("Drive Random: register = %d data = %d, xval = %d, register_temp = %d",rnd.register,rnd.data,rnd.xval,register_temp);
		write_register(rnd.register, rnd.data, rnd.xval);
	endtask

endclass
`endif 

