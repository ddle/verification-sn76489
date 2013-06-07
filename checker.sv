`ifndef GUARD_CHECKER 
`define GUARD_CHECKER
`include "scoreboard.sv"
`include "monitor.sv"

	class checker_;
        	scoreboard sb;
        	virtual intf_sn76489 intf;
		monitor mnt;
		int magnitude_values [16] = {31,25,20,16,12,10,8,6,5,4,3,2,2,2,1,0};
        
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
				if (intf.end_of_test && sb.checked[generator] == 1 && sb.modified[generator] == 0) break;
				if (intf.det_done_out[generator]) begin
					// check if modified bit is set
					if (sb.modified[generator]) begin
						//sb.modified[generator] = 0;
						$display("Ignoring...");
						continue; // ignore this current configuration
					end
					// check freq ???
					if (intf.det_counter_out[generator] == 0) begin
						$display("Warning - frequency detected = 0\tgenerator %d\tpacket %d",generator,sb.packet_number);					
					end
					else if (sb.frequency[generator] != intf.det_counter_out[generator] || 
						magnitude_values[sb.attenuation[generator]] != intf.det_magnitude_out[generator] ) begin

						// packet id...?
						current_packet.exp_frequency = sb.frequency[generator];
						current_packet.act_frequency = intf.det_counter_out[generator];
						current_packet.exp_attenuation = sb.attenuation[generator];
						current_packet.act_attenuation= intf.det_magnitude_out[generator];
						mnt.error_count++;
						mnt.error_packet_q.push_back(current_packet);
						$display("ERROR: output mismatch\tgen: %d\tfreq %d\texp freq %d\tmag %d\texp mag %d\tpacket %d",generator,intf.det_counter_out[generator],sb.frequency[generator],intf.det_magnitude_out[generator],magnitude_values[sb.attenuation[generator]],sb.packet_number);
					end
					else $display("Check succeded\tgenerator: %d\tfrequency %d\tmagnitude %d\tpacket %d",generator,intf.det_counter_out[generator],intf.det_magnitude_out[generator],sb.packet_number);
					// notify check status
					sb.checked[generator] = 1;
				
				end
				else begin
					//sb.checked[generator] = 0;
				end

			end
		endtask
	endclass
`endif
