////////////////////////////////////////////////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////s           www.testbench.in           s////
////s                                      s////
////s        SystemVerilog Tutorial        s////
////s                                      s////
////s           gopi@testbench.in          s////
////s~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~s////
////////////////////////////////////////////////
`include "env.sv"
program testcase(intf_cnt intf);
  environment env = new(intf);
  
  initial
  begin
    // parallel checking
	fork 
        env.mntr.check();
    join_none	
			  
	// driving test case
    env.drvr.reset();
    env.drvr.drive(100);
    env.drvr.reset();
    env.drvr.drive(100);
    
	$stop;
	
  end
endprogram
