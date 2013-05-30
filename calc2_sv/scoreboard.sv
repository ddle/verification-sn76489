
`ifndef GUARD_SCOREBOARD 
`define GUARD_SCOREBOARD 

`include "calc2_port.sv"
/*
    typedef struct {
        calc2_port_out expect_out; // expect output of port in calc1 design
        int response_time; // expected response time (in-out) of port, evaluate output at 0         
    } expect_output_t;

    typedef expect_output_t expect_output_q[$];
*/
	// this makes a queue of type calc2_port_out
	// since each out port can queue up output
    typedef calc2_port_out expect_output_q[$];
	
    class scoreboard;
        expect_output_q    exp_ports[4];  // we have 4 out ports
	    bit                in_use[4][4];  // keep track of tag usage, format is in_use[port][tag]
        //bit [0:3] pending_ports; 
		bit                cmd_pending[4];   // set when a command is pending (wait for data_2)
	   
    endclass

`endif 
