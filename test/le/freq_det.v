module freq_det(
    input               clk,			
    input       [7:0]   in_signal,		// signal to be detected	
	output  reg [9:0]   out_counter,   // output counter value
	output  reg         done,   
	output  reg [7:0]   out_magnitude
);

reg	[9:0]	counter = 0;
// register for the counter outputs 
// register previous level of the pwm signal
reg	[7:0]	previous_level = 0;
reg reset_counter = 0;

// counting half period duration of the input signal ( signal is 50% duty cycle )
always @ (posedge clk)	begin
	if (reset_counter) begin
		counter <= 0;			
	end	
	else begin
		counter = counter + 1;
	end		
end

// registering previous level
always  @ (posedge clk) begin	
	previous_level <= in_signal;
	out_magnitude <= in_signal;
end

// registering counter output when signal changes level, then reset counter 
always @ (posedge clk)	begin
	if ( previous_level != in_signal ) begin 
		out_counter <= counter;		
		reset_counter <= 1;
		done <= 1;
	end	
	else begin
		out_counter <= out_counter;		
		reset_counter <= 0; 
		done <= 0;
	end
end

endmodule
