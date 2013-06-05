
`ifndef GUARD_INTF 
`define GUARD_INTF 

 interface intf_sn76489(input clk);

  logic					clock_en_i;
  logic					res_n_i;
  logic					ce_n_i;
  logic					we_n_i; 
  logic					ready_o;
  logic		[0:7]	d_i; 
  logic		[0:7]	tone1_out_o;
	logic		[0:7]	tone2_out_o;
	logic		[0:7]	tone3_out_o;
	logic		[0:7]	noise_out_o;
	logic		[0:7]	aout_o;

	int end_of_test;
 endinterface

`endif 
