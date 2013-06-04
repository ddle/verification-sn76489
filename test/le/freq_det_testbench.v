module top;
	reg [7:0] freq;
	reg clk;
	wire [9:0] counter;
	wire done;
	
	initial  begin// clock generator
		clk = 0;
		forever #5 clk = ~clk;
	end

	initial  begin// clock generator
		freq = 0;
		forever #500 freq = ~freq;
	end
	
	freq_det det( .clk(clk),			
				  .in_signal(freq),		// signal to be detected	
				  .out_counter(counter),   // output counter value
				  .done(done)
	);	

	
	
	initial begin
		#10000 $stop;
	end


	
endmodule

