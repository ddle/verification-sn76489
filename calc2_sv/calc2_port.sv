  `ifndef GUARD_calc_port 
`define GUARD_calc_port

  typedef struct {
        logic [0:3] req_cmd_in;
        logic [0:31] req_data_in;
		logic [0:1] req_tag_in;
    } calc2_port_in;
    
    typedef struct {
        logic [0:1] out_resp;
        logic [0:31] out_data;        
		logic [0:1] out_tag;
    } calc2_port_out;

`endif
