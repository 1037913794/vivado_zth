
module DMem(DataOut,DataAdr,DataIn,DMemW,DMemR,clk,sel,disp);
	input [7:0] DataAdr,sel;
	input [31:0] DataIn;
	input 		 DMemR;
	input 		 DMemW;
	input 		 clk;
	
	output[31:0] DataOut,disp;
	
	reg [31:0]  DMem[255:0];
	
	always@(posedge clk)
	begin
		if(DMemW)
			 DMem[DataAdr] <= DataIn;
			 $display("addr=%8X",DataAdr);//addr to DM
       $display("din=%8X",DataIn);//data to DM
       $display("Mem[00-07]=%8X, %8X, %8X, %8X, %8X, %8X, %8X, %8X",DMem[0],DMem[1],DMem[2],DMem[3],DMem[4],DMem[5],DMem[6],DMem[7]);
	end
	assign DataOut = DMem[DataAdr];
    assign disp = DMem[sel];
endmodule