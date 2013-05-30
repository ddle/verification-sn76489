
`ifndef GUARD_STIMULUS 
`define GUARD_STIMULUS 



class stimulus;
  
  rand bit [0:31] calc2_data_1;
  rand bit [0:31] calc2_data_2;
  constraint limit_c { 
	calc2_data_1 dist {
		[0:1000] := 50,
		[1001:2000] := 50
	};
  }
  constraint limit_b { calc2_data_2 < 2000;} 
endclass

`endif 
