
`include "env.sv"
  program testcase(intf_cnt intf);
	class rand_vars;
        rand int op,port,d1,d2;
		constraint legal {
			op >=0; 
			op <=4;
			port >=0;
			port <=3;
			
		}

	endclass
         environment env = new(intf);
         initial begin
			static rand_vars r = new ();
			static int a,b;
			  //#400
			  // start checker  	
			  fork 
                 env.mntr.check_calc2();
              join_none	
			  
			  // driving test case
              env.drvr.reset();
              #400
              repeat(2) begin
			  // fork
				if (r.randomize() == 1) begin				  
 	                //env.drvr.drive_calc2(r.port,r.op, 4,3,0);
					
					env.drvr.drive_calc2(1, 1, 4,3,0);
					//env.drvr.drive_calc2(2, 1, 4,3,0);
					//@ (posedge intf.clk); // next clk edge
					@ (posedge intf.clk); // next clk edge
					@ (posedge intf.clk); // next clk edge
					@ (posedge intf.clk); // next clk edge
					env.drvr.drive_calc2(1, 1, 4,3,1);
					@ (posedge intf.clk); // next clk edge
					@ (posedge intf.clk); // next clk edge
					@ (posedge intf.clk); // next clk edge
					//env.drvr.drive_random_data((a++) % 5, (b++) % 4);
				end
			  // join_none
				
			  end
			  #400
              $stop;  
            
            
         end
    endprogram
