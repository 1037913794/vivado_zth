module PcUnit(PC,PcReSet,PcSel,Adress,Jump,Jumpaddr,clk,pause);

	input   PcReSet;
	input   PcSel;
    input   Jump;
	input   clk;
    input   pause;
	input   [31:0] Adress;
    input   [25:0] Jumpaddr;
	
	output reg[31:0] PC;
	
	reg [31:0] temp;
	always@(posedge clk or posedge PcReSet)
	begin
		if(PcReSet == 1)
			PC <= 32'h0000_0000;
		else
            begin
                if((PC <= 32'h0000_006c) && (pause == 0))
                    PC = PC+4;
                if(PcSel == 1)
                    begin
                        /* for(i=0;i<30;i=i+1)
                            temp[31-i] = Adress[29-i];
                        temp[0] = 0;
                        temp[1] = 0; */
                        temp = Adress << 2;
                        PC = PC+temp;
                    end
                if(Jump == 1)
                    begin
                        temp[27:2] = Jumpaddr[25:0];
                        temp[1:0] = 2'b00;
                        PC = {PC[31:28], temp[27:0]};
                    end
            end
	end
endmodule
	
	