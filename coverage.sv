`ifndef GUARD_COVERAGE 
`define GUARD_COVERAGE


`include "scoreboard.sv"

class sn_coverage;
	scoreboard sb;

	covergroup chip_coverage;
		// collect freq coverage
		generator_0_frequency : coverpoint sb.frequency[0]; 
		generator_1_frequency : coverpoint sb.frequency[1]; 
		generator_2_frequency : coverpoint sb.frequency[2]; 
		generator_3_frequency : coverpoint sb.frequency[3]; 

		// collect attenuation coverage
		generator_0_attenuation : coverpoint sb.attenuation[0]; 
		generator_1_attenuation : coverpoint sb.attenuation[1]; 
		generator_2_attenuation : coverpoint sb.attenuation[2]; 
		generator_3_attenuation : coverpoint sb.attenuation[3]; 
		
		// cross data
		/*all_cross: cross	generator_0_frequency,generator_1_frequency,
							generator_2_frequency,generator_3_frequency, 
							generator_0_attenuation,generator_1_attenuation, 
							generator_2_attenuation,generator_3_attenuation;
*/
	endgroup

	function new(); 
		chip_coverage = new(); 		
	endfunction

	task sample(scoreboard sb); 
		this.sb = sb;
		chip_coverage.sample(); 
	endtask

endclass

`endif