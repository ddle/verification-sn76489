`ifndef GUARD_RAND 
`define GUARD_RAND

	class rand_test_case;
    rand int register,data;
		rand bit xval;
		int latched_reg;
		constraint legal 
		{
			// register is the register to change (0-7),(8 uses latched register)
			register >=0; 
			register <=5;
			if(register == 6 || (register == 8 && latched_reg == 6))
			{
			data >=0;
			data <= 7;
			}
			else if(register[0] == 0 || (register == 8 && latched_reg[0] == 0))
			{
			data >=1;
			data <= 1023;
			}
			else
			{
			data >=0;
			data <= 15;
			}
		}

		function new (int seed); 
			srandom(seed); 
			latched_reg = -10;
			$display(" SEED is initialised to %0d ",seed); 
		endfunction 

		function void pre_randomize; 
			if(register < 8) latched_reg = register; 
		endfunction 
	
		function void post_randomize;
//			$display("Random Values: %d %d",register,data);
//			if(register == 8 && latched_reg < 0) register = 1;
//			if((register == 0 || register == 2 || register == 4) && data == 0) data = 1;
		endfunction

	endclass
`endif

