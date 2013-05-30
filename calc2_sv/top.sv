

  module top();
    reg clk = 0;
    wire 	 scan_out;
   
   
    reg 	 a_clk;
    reg 	 b_clk;
    reg 	 c_clk;   
    reg 	 reset;
    reg	 scan_in;
   
   
   
    initial  begin// clock generator
	  	#50
		forever #50 clk = ~clk;
    end
	
    // DUT/assertion monitor/testcase instances
    intf_cnt intf(clk);
   
    calc2_top D1(
	   intf.out_ports[0].out_data, intf.out_ports[1].out_data, intf.out_ports[2].out_data, intf.out_ports[3].out_data,
	   intf.out_ports[0].out_resp, intf.out_ports[1].out_resp, intf.out_ports[2].out_resp, intf.out_ports[3].out_resp, 
	   intf.out_ports[0].out_tag,  intf.out_ports[1].out_tag,  intf.out_ports[2].out_tag,  intf.out_ports[3].out_tag,
	   scan_out, a_clk, b_clk, clk,
       intf.in_ports[0].req_cmd_in, intf.in_ports[0].req_data_in, intf.in_ports[0].req_tag_in,
	   intf.in_ports[1].req_cmd_in, intf.in_ports[1].req_data_in, intf.in_ports[1].req_tag_in,
	   intf.in_ports[2].req_cmd_in, intf.in_ports[2].req_data_in, intf.in_ports[2].req_tag_in,
       intf.in_ports[3].req_cmd_in, intf.in_ports[3].req_data_in, intf.in_ports[3].req_tag_in,
	   intf.calc2_reset, scan_in);
      
      //ones_counter DUT(clk,intf.reset,intf.data,intf.count);
      testcase test(intf);
      assertion_cov acov(intf);
    
    always @ (posedge clk) 
     //@ (reset or clk or intf.in_ports[0].req_cmd_in or intf.in_ports[0].req_data_in or intf.out_ports[0].out_data or intf.out_ports[0].out_resp) 
     begin
	
	//$display ("%d \t %d \t %d \t %d", intf.in_ports[0].req_cmd_in, intf.in_ports[0].req_data_in, intf.out_ports[0].out_data, intf.out_ports[0].out_resp);
	
    end
    initial 
    begin
      c_clk = 0;
	  a_clk = 0;
	  b_clk = 0;
	  scan_in = 0;	
	end
	
   endmodule
