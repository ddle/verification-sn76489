`ifndef GUARD_CHECKER 
`define GUARD_CHECKER
`include "scoreboard.sv"
`include "monitor.sv"

	class checker_;
        	scoreboard sb;
        	virtual intf_sn76489 intf;
		monitor mnt;
        
        	function new(virtual intf_sn76489 intf,scoreboard sb, monitor mnt);
           	 	this.intf = intf;
           	 	this.sb = sb;
			this.mnt = mnt;
        	endfunction

		task check(int generator); // check freq and magnitude
			packet_t current_packet;
			forever begin
				// on "done" signal, check freq detector outputs with values on scoreboard
		       	@ (posedge intf.clk); // operate on clk edge
				if (intf.det_done_out[generator]) begin
					// check if modified bit is set
					if (sb.modified[generator]) begin
						sb.checked[generator] = 0;
						continue; // ignore this current configuration
					end
					// check freq ???
					if (sb.frequency[generator] != intf.det_counter_out[generator] || 
						sb.attenuation[generator] != intf.det_magnitude_out[generator] ) begin

						// packet id...?
						current_packet.exp_frequency = sb.frequency[generator];
						current_packet.act_frequency = intf.det_counter_out[generator];
						current_packet.exp_attenuation = sb.attenuation[generator];
						current_packet.act_attenuation= intf.det_magnitude_out[generator];
						mnt.error_count++;
						mnt.push_back(current_packet);
						$display("ERROR: output mismatch");
					end
					// notify check status
					sb.checked[generator] = 1;
				
				end
				else begin
					sb.checked[generator] = 0;
				end

			end
		endtask
	endclass
`endif
