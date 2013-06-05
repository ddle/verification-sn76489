
`ifndef GUARD_MONITOR 
`define GUARD_MONITOR

typedef struct {
	int packet_id;

	int exp_frequency;  // expect output
	int exp_attenuation;

	int act_frequency;  // actual output
	int act_attenuation;
	
	// time ...
	/* ... */
    } packet_t;

typedef packet_t packet_queue[$];

    class monitor;
        packet_queue    error_packet_q;
	 int             error_count;
    endclass

	function new();
		this.error_count = 0;
       endfunction
`endif 
