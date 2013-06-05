
`ifndef GUARD_SCOREBOARD 
`define GUARD_SCOREBOARD 

//	Scoreboard class stores information on the current settings of the SN76489 DUV.
//  The frequency and attenuation of each generator is stored, as well as two bits for
//  storing the current status of the verification.
//	modified[generator] is used to notify if the frequency has changed between checks.
//		If the frequency has changed, the checker value may not be valid, so the modified
//		flag is unset and the current period ignored.
//	checked[generator] is used to tell the driver if the current frequency has been checked
//		successfully (meaning the modified flag was not set when the check was requested).
//		This tells the driver if it can make a new change.
	
	class scoreboard;
		int 				frequency[4];			
		int					attenuation[4];
		bit						modified[4];					// This is set when a new frequency is set on a generator, 
																				// when the checker presents a period count to verification
																				// if this is set, it will unset it and ignore the results.
		bit						checked[4];						// This is set when the checker has checked the frequency of a generator


		// new() sets all frequency and attenuation values to -1 (initial values unspecified on datasheet)
		// and sets all modified to 1 (period check is invalid), and checked to 1 (driver may send new command)
		function new();
			this.frequency[0] = 1;
			this.frequency[1] = 5;

			foreach( this.frequency[j] )
				this.frequency[j] = -1;

			foreach( this.attenuation[j] )
				this.attenuation[j] = -1;
			
			foreach( this.modified[j] )
				this.modified[j] = 1;

			foreach( this.checked[j] )
				this.checked[j] = 1;
		endfunction

		function bit is_checked(int generator);
			return 1;//this.checked[generator];
		endfunction

		function int check_frequency(int generator, int period);
			if ( this.modified[generator] )
				begin
					this.modified[generator] = 0;
					return -1;
				end
			else 
				begin
					if ( this.frequency[generator] == period )
						return 1;
					else 
						return 0;
					this.checked[generator] = 1;
					$display("this.modified[generator]: %d, period: %d", this.modified[generator], period);
					return period;
				end
		endfunction
				
		function int check_attenuation(int generator, int attenuation);
			if ( this.attenuation[generator] == attenuation )
				return 1;
			else 
				return 0;
		endfunction

		function int set_frequency(int generator, int frequency);
			this.modified[generator] = 1;
			this.checked[generator] = 0;
			this.frequency[generator] = frequency;
			return 1;
		endfunction;

		function int set_attenuation(int generator, int attenuation);
			this.attenuation[generator] = attenuation;
			return 1;
		endfunction;

	endclass

`endif 
