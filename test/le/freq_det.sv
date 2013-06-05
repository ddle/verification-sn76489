`ifndef GUARD_FREQ_DET
`define GUARD_FREQ_DET

`include "scoreboard.sv"
	class freq_det;
        	virtual intf_sn76489 intf;
        	int DONE[4];
		int count
        	function new(virtual intf_sn76489 intf);
            		this.intf = intf;
			this.DONE = 0;
        	endfunction

		task start_all();
			$display("freq_det module started");
			forever begin
				
			end
		endtask
		
		
	endclass
`endif
