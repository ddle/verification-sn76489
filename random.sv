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
			register <=8;
			data >=0;
			data <= (2^10)-1;
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
			if(register == 8 && latched_reg < 0) register = 1;
			if((register == 0 || register == 2 || register == 4) && data == 0) data = 1;
		endfunction

	endclass
`endif

