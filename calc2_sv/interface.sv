
`ifndef GUARD_INTF 
`define GUARD_INTF 

`include "calc2_port.sv"

 interface intf_cnt(input clk);

    logic             calc2_reset;
    calc2_port_in     in_ports[4];
    calc2_port_out    out_ports[4];

	int end_of_test;
 endinterface

`endif 

