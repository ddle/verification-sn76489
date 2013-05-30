
`ifndef GUARD_MONITOR 
`define GUARD_MONITOR

`include "scoreboard.sv"


	class monitor;
        scoreboard sb;
        virtual intf_cnt intf;
        
        function new(virtual intf_cnt intf,scoreboard sb);
            this.intf = intf;
            this.sb = sb;
        endfunction
          
/*
          task check_calc1();
			  $display("checker started");
              forever begin					
				  @ (posedge intf.clk);
				  for ( int count = 0; count < 4; count++) begin
					  if (sb.exp_ports[count].size()>0) begin
						  
						  expect_output_t test = sb.exp_ports[count].pop_front(); 					  
						  
						  if (test.response_time == 0) begin					  
							if ( (intf.out_ports[count].out_data != test.expect_out.out_data) ||				
							(intf.out_ports[count].out_resp != test.expect_out.out_resp)) begin							
								$display("****ERROR on port %d: DUT %d %d:: SB %d %d", count,
								intf.out_ports[count].out_data,
								intf.out_ports[count].out_resp,
								test.expect_out.out_data, 
								test.expect_out.out_resp );							
							end
							sb.pending_ports[count] = 0; // operation completed
						  end						  
						  else begin							
							test.response_time--;
							sb.exp_ports[count].push_front(test);						
						  end
						  
					  end
						  //$display(" queue empty " );
				  end
              end  
          endtask
*/
		int timeout[4] = {3,3,3,3}; // timeout for 4 port 
		task check_calc2();
			$display("checker started");
            forever begin					
				@ (posedge intf.clk);
				for ( int count = 0; count < 4; count++) begin
					$display("time:%d \t port:%d data: %d  resp: %d tag: %d", $time/100, count,
						intf.out_ports[count].out_data,
						intf.out_ports[count].out_resp,
						intf.out_ports[count].out_tag						
					);		
					// check response in output.
					// our queue is first in - first out and the DUV is designed as in-order retirement
					// so we only need to check the queue front 's packet. If there are something in the queue, we 
					// should get response in no more than 2 cycles, otherwise throw an error msg and remove the packet.
					// correctness of later packets are not guaranteed anymore
					
					if (sb.exp_ports[count].size()>0) begin	// something in queue, expecting output			
						// 
						if ( intf.out_ports[count].out_resp != 0 ) begin 						
							// get the front packet of the current port
							calc2_port_out test = sb.exp_ports[count].pop_front();	// FIXME: need locking during pop and push
							// output is incorrect
							if ( (intf.out_ports[count].out_data != test.out_data) ||				
							   (intf.out_ports[count].out_resp != test.out_resp)  ||
							   (intf.out_ports[count].out_tag != test.out_tag))   begin							
								$display("****ERROR on port %d: DUT %d %d:: SB %d %d", count,
								intf.out_ports[count].out_data,
								intf.out_ports[count].out_resp,
								test.out_data, 
								test.out_resp );
								timeout[count] = 3;
								sb.in_use[count][intf.out_ports[count].out_tag] = 0;
							end		
							else begin // success
								timeout[count] = 3;
								sb.in_use[count][intf.out_ports[count].out_tag] = 0;
								$display("packet ok: data %d resp %d tag %d in_use: %d", intf.out_ports[count].out_data,
								intf.out_ports[count].out_resp, intf.out_ports[count].out_tag, 
								sb.in_use[count][intf.out_ports[count].out_tag]);
								
							end
							
						end
						else begin // no response, wait to next cycle or throw timeout error
							if (timeout[count] == 0) begin							
								$display("timeout, remove packet");
								sb.exp_ports[count].pop_front();
							end
							else
								timeout[count]--;
						end
					end
				end
            end  
        endtask
		  
		  
	endclass

`endif 
