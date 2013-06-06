	

`ifndef GUARD_STIM 
`define GUARD_STIM

`include "interface.sv"

// stimuls class for SN76489 Complex Sound Generator chip verification.

class stimulus_sn76489;

	
	virtual intf_sn76489		intf;			// interface to DUV.
	scoreboard			sb;				// scoreboard

	function new(virtual intf_sn76489 intf,scoreboard sb);
		this.intf = intf;
		this.sb = sb;
	endfunction

	task init(); 
		intf.ce_n_i = 0;
		intf.we_n_i = 1; 
		intf.d_i = 0; 
		@ (posedge intf.clk);	
	endtask

// test case 1.  Verify function of READY output according to table 5 of SN76489 datasheet.
	task test_1();
		// 1.1 Set CE and WE to 11, verify READY output is 1
		intf.ce_n_i = 1;
		intf.we_n_i = 1; 		
		@ (posedge intf.clk);		
		
		if (intf.ready_o == 0)
			$display("error on test case 1.1");
		else 
			$display("test case 1.1 passed");

		// 1.2 Set CE and WE to 10, verify READY output is 1
		intf.ce_n_i = 1;
		intf.we_n_i = 0; 		

		@ (posedge intf.clk);
			$display("test case 1.2...");		
		if (intf.ready_o == 0)
			$display("error on test case 1.2");
		else 
			$display("test case 1.2 passed");

		// 1.3 Set CE and WE to 01, verify READY output is 0
		intf.ce_n_i = 0;
		intf.we_n_i = 1; 		
		@ (posedge intf.clk);
			$display("test case 1.3...");		
		if (intf.ready_o == 1)
			$display("error on test case 1.3");
		else 
			$display("test case 1.4 passed");

		// 1.4 Set CE and WE to 00, verify READY output is 0
		intf.ce_n_i = 0;
		intf.we_n_i = 0; 		
		@ (posedge intf.clk);
		
		if (intf.ready_o == 1)
			$display("error on test case 1.4");
		else 
			$display("test case 1.4 passed");

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

	task write_register(int register, int data);
		bit [2:0] register_bits = register;
		bit [9:0] data_bits = data;
		bit [7:0] command_byte,command_byte2;
		bit second_byte = 0;

		$display("command byte - register: %d value: %d", register_bits, data_bits);

		if (register == 0 || register == 2 || register == 4) begin
			// Tone generator frequency registers
			command_byte = {1'b1,register_bits,data_bits[3:0]};
			command_byte2 = {1'b0,1'b1,data_bits[9:4]};
			second_byte = 1;
			$display("tone generator register - %d %d", command_byte, command_byte2);
		end
		else if (register == 6) begin
			// Noise source register
			command_byte = {1'b1,register_bits,1'b0,data_bits[2:0]};
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

		drive_byte(command_byte);
		if (second_byte) drive_byte(command_byte2);

	endtask			// write_register


endclass
`endif 

