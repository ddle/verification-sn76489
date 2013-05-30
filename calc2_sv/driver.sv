
`ifndef GUARD_DRIVER 
`define GUARD_DRIVER 

`include "stimulus.sv"
`include "scoreboard.sv"
`include "calc2_port.sv"
  class driver;
        stimulus sti;
        scoreboard sb;
	
  //=================================================
  // Coverage Group for cmd in
  //=================================================
  covergroup cmd_cg;
    port1_cmd : coverpoint intf.in_ports[0].req_cmd_in 
	{
      bins add    = {1};
      bins sub    = {2};
      bins shiftleft   = {3};
	  bins shiftright   = {4};
    } 
	port2_cmd : coverpoint intf.in_ports[1].req_cmd_in 
	{
      bins add    = {1};
      bins sub    = {2};
      bins shiftleft   = {3};
	  bins shiftright   = {4};
    } 
	port3_cmd : coverpoint intf.in_ports[2].req_cmd_in 
	{
      bins add    = {1};
      bins sub    = {2};
      bins shiftleft   = {3};
	  bins shiftright   = {4};
    } 
	port4_cmd : coverpoint intf.in_ports[3].req_cmd_in 
	{
      bins add    = {1};
      bins sub    = {2};
      bins shiftleft   = {3};
	  bins shiftright   = {4};
    } 	
  endgroup
  //=================================================
  // Coverage Group for data in
  //=================================================
  covergroup data_cg;
    port1_data : coverpoint intf.in_ports[0].req_data_in 
	{
      bins low    = {0,1000};
      bins high    = {1001,2000};
     
    } 
	port2_data : coverpoint intf.in_ports[1].req_data_in 
	{
      bins low    = {0,1000};
      bins high    = {1001,2000};
    
    } 
	port3_data : coverpoint intf.in_ports[2].req_data_in 
	{
      bins low    = {0,1000};
      bins high    = {1001,2000};
    
    } 
	port4_data : coverpoint intf.in_ports[3].req_data_in 
	{
      bins low    = {0,1000};
      bins high    = {1001,2000};
     
    } 	
  endgroup
  //=================================================
  // Instance of covergroup
  //=================================================
  //  cmd_cv cmd_cg = new();
  
        virtual intf_cnt intf;
        
        function new(virtual intf_cnt intf,scoreboard sb);
             this.intf = intf;
             this.sb = sb;
             //cov = new();
			   cmd_cg = new();
			   data_cg = new();

        endfunction
        
        task reset();  // Reset method
			 
			 intf.end_of_test = 0;
			              
             intf.in_ports[0].req_data_in = 0;
             intf.in_ports[1].req_data_in = 0;
             intf.in_ports[2].req_data_in = 0;
             intf.in_ports[3].req_data_in = 0;
			 
             intf.in_ports[0].req_cmd_in = 0;
             intf.in_ports[1].req_cmd_in = 0;
             intf.in_ports[2].req_cmd_in = 0;
             intf.in_ports[3].req_cmd_in = 0;
			 
			 intf.in_ports[0].req_tag_in = 0;
             intf.in_ports[1].req_tag_in = 0;
             intf.in_ports[2].req_tag_in = 0;
             intf.in_ports[3].req_tag_in = 0;			 
			 
             @ (posedge intf.clk);
             intf.calc2_reset = 0;
             @ (posedge intf.clk);
             intf.calc2_reset = 1;
             @ (posedge intf.clk);
             intf.calc2_reset = 0;
			 
            $display("reset");  
        endtask
        
                       
        // drive_random_data():
        // send a command to DUT:
        //   No operation “0000”b
        //   Add          “0001”b
        //   Subtract     “0010”b
        //   Shift_left   “0101”b
        //   Shift_right  “0110”b
        //   Invalid All others
        // port : 0-3
        // This task should be forked when called
        task drive_calc2(input int port, input int cmd, input int data_1, input int data_2, input int tag); 
            calc2_port_out out;
 
            int resp_time = 0;               
            calc2_port_out exp_out;
            int count;

			cmd_cg.sample();
			
            @ (posedge intf.clk); // operate on clk edge
			
			// see if we can drive this port: tag available and 2 cycle delay b/w cmd
			if (!sb.in_use[port][tag] && !sb.cmd_pending[port]) begin
				// claim it
				sb.in_use[port][tag] = 1; // this will be cleared in monitor when output is available
				sb.cmd_pending[port] = 1; // 
				
				exp_out.out_tag = tag;				
				$display("port %d", port);				
				case(cmd)
					0: begin //no cmd, no response 
							exp_out.out_data = 0;
							exp_out.out_resp = 0;
					   end 
					1: begin // add
							$display("\ndo add %d %d", data_1, data_2);
							exp_out.out_data = data_1 + data_2;                 
						   // $display("=", exp_out.expect_out.out_data); 
							if (exp_out.out_data < data_1) begin //overflow
								exp_out.out_resp = 2;
								exp_out.out_data = 0;
							end 
							else begin                                
							   exp_out.out_resp = 1; // success
							end
					   end 
					2: begin // subtract
							$display("\ndo sub %d %d", data_1, data_2);
							if (data_1 < data_2) begin //under flow
								exp_out.out_resp = 2;
								exp_out.out_data = 0;
							end 
							else begin  
							   exp_out.out_data = data_1 - data_2;                 		
							   exp_out.out_resp = 1; // success
							end
					   end 
					3: begin // shift left                         
							$display("\ndo shift left %d %d", data_1, data_2);
							data_2 &= ~('hffffffe0); // clear 27 upper bit
							exp_out.out_data = data_1 << data_2;                 		
							exp_out.out_resp = 1; // success                            
					   end	
					4: begin // shift right                         
							$display("\ndo shift right %d %d", data_1, data_2);
							data_2 &= ~('hffffffe0); // clear 27 upper bit
							exp_out.out_data = data_1 >> data_2;                 		
							exp_out.out_resp = 1; // success                            
					   end 
					default: begin // invalid
							$display("\ndo invalid %d %d", data_1, data_2);
							exp_out.out_data = 0;                 		
							exp_out.out_resp = 2; // success                           
						end	
				endcase					 
					 $display("expect out data : %d\n",exp_out.out_data);

				sb.exp_ports[port].push_back(exp_out);   // first in, first out
				
				// Drive to DUT
				intf.in_ports[port].req_data_in = data_1; 
				intf.in_ports[port].req_cmd_in = cmd;
				intf.in_ports[port].req_tag_in = tag;
				
				cmd_cg.sample();
				data_cg.sample();
				
				@ (posedge intf.clk); // next clk edge
				//@ (negedge intf.clk); // next clk edge
				
				intf.in_ports[port].req_data_in = data_2;
				intf.in_ports[port].req_cmd_in = 0;			
				intf.in_ports[port].req_tag_in = 0;
				
				data_cg.sample();
				
				@ (posedge intf.clk); // next clk edge
				//@ (negedge intf.clk); // next clk edge
				
				intf.in_ports[port].req_data_in = 0; 
				sb.cmd_pending[port] = 0; // release cmd bus for later drive

				
				//end
            
			end
			else begin
				$display("warning port %d busy (tag unavailable: %d or need 2 cycle delay b/w cmd: %d), drop packet", port,
				sb.in_use[port][tag], sb.cmd_pending[port] );
			end
			
        endtask

        
   endclass

`endif 
