
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
 
	task command_byte(int register, int data);
		bit [2:0] register_bits = register;
		bit [9:0] data_bits = data;
		$display("command byte - register: %d value: %d", register_bits, data_bits);
		if (intf.ce_n_i == 0)
			if (intf.we_n_i == 1) begin
				if (register == 0 || register == 2 || register == 4) begin
					// Tone generator frequency registers
					$display("tone generator register: %x value: %x", register_bits, data_bits);
					intf.d_i = {1'b1,register_bits,data[3:0]};
					intf.we_n_i = 0;
					@ (posedge intf.ready_o);
					intf.d_i = {1'b0,1'b0,data[9:4]};				
					@ (posedge intf.ready_o);
					intf.we_n_i = 1;	
					intf.d_i = 0;					
				end
				else if (register == 6) begin
					// Noise source register
					intf.d_i = {1'b1,register_bits,1'b0,data[2:0]};
					intf.we_n_i = 0;
					@ (posedge intf.ready_o);
					intf.we_n_i = 1;	
					intf.d_i = 0;		
				end
				else if (register == 1 || register == 3 || register == 5 || register == 7) begin
					// Attenuation register
					intf.d_i = {1'b1,register_bits,1'b0,data[3:0]};
					intf.we_n_i = 0;
					@ (posedge intf.ready_o);
					intf.we_n_i = 1;	
					intf.d_i = 0;		
				end						
			end 
	endtask

endclass
`endif 

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
						data_bits >> 4;
					end
					intf.d_i = {1'b0,1'b0,data_bits[5:0]};	
				end

				// activate write enable and wait for ready to go high.
				intf.we_n_i = 0;
				@ (posedge intf.ready_o);
				
				// if second byte is needed (frequency registers)
				if (register == 0 || register == 2 || register == 4) begin
					data_bits >> 4;					
					intf.d_i = {1'b0,1'b0,data_bits[5:0]};	
					@ (posedge intf.ready_o);
				end

				//deactivate write enable after ready signal has gone high.
				intf.we_n_i = 1;

			end 
			else $display("Command failed due to we_n_i being asserted low");
		end
	else $display("Command failed due to ce_n_i being asserted low");
	endtask			// command byte

endclass
`endif 

