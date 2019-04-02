module Mips(Clock,Reset,sw_i,led_o,o_seg,o_sel);
    input   Clock,Reset;
    input   [15:0]  sw_i;
    output  [7:0]   o_seg,o_sel;
    output  [15:0]  led_o;
//PC
    wire [31:0] pcOut;
//IM	
    wire [7:0]  imAdr;
    wire [31:0] opCode;
//GPR
    wire [4:0]  gprWeSel,gprReSel1,gprReSel2;
    wire [31:0] gprDataIn;
    wire [31:0] gprDataOut1,gprDataOut2;
//Extender
    wire [15:0] extDataIn;
    wire [31:0] extDataOut;
//DMem
    wire [7:0]  dmDataAdr;
    wire [31:0] dmDataOut;
//Ctrl
    wire [25:0] jumpaddr;
    wire [5:0]	op;
    wire [5:0]	funct;
    wire 		jump;						//指令跳转
    wire 		RegDst;						
    wire 		Branch;						//分支
    wire 		MemR;						//读存储器
    wire 		Mem2R;						//数据存储器到寄存器堆
    wire 		MemW;						//写数据存储器
    wire 		RegW;						//寄存器堆写入数据
    wire		Alusrc;						//运算器操作数选择
    wire [1:0]  ExtOp;						//位扩�?/符号扩展选择
    wire [4:0]  Aluctrl;					//Alu运算选择
//Alu
    wire [31:0] aluDataIn2;
    wire [31:0]	aluDataOut;
    wire 		zero;
//Other
    wire        pcSel;
    wire        clk;                        //分频后的信号
    wire [31:0] disp_data;
    assign pcSel = ((Branch&&zero)==1)?1:0;
    assign imAdr = pcOut[9:2];
    assign jumpaddr = opCode[25:0];
    assign op = opCode[31:26];
    assign funct = opCode[5:0];
    assign gprReSel1 = opCode[25:21];
    assign gprReSel2 = opCode[20:16];
    assign gprWeSel = (RegDst==0)?opCode[20:16]:opCode[15:11];
    assign extDataIn = opCode[15:0];
    assign dmDataAdr = aluDataOut[9:2];
    assign gprDataIn = (Mem2R==1)?dmDataOut:aluDataOut;
    assign aluDataIn2 = (Alusrc==1)?extDataOut:gprDataOut2;
    //15:分频控制位
    //14:指令暂停控制位
    //13:预留
    //12:预留
    //11-8:数码管显示内容选择位
    //7-0:内存地址位(共256个存储单元)
    assign led_o[15] = clk;
    assign led_o[14] = ;
    assign led_o[13] = ;
    assign led_o[12] = ;
    assign led_o[11] = ;
    assign led_o[10] = ;
    assign led_o[9] = ;
    assign led_o[8] = ;
    assign led_o[7] = jump;
    assign led_o[6] = RegDst;
    assign led_o[5] = Branch;
    assign led_o[4] = MemR;
    assign led_o[3] = Mem2R;
    assign led_o[2] = MemW;
    assign led_o[1] = RegW;
    assign led_o[0] = Alusrc;
    case(sw_i[11:8])
        0 : assign disp_data = (RegW)?gprDataIn:((MemW)?gprDataOut2:pcOut);
        1 : assign disp_data = U_DMem.DMem[sw_i[7:0]];
        2 : assign disp_data = ;
        3 : assign disp_data = ;
        4 : assign disp_data = ;
        5 : assign disp_data = ;
        6 : assign disp_data = ;
        7 : assign disp_data = ;
        8 : assign disp_data = ;
        9 : assign disp_data = ;
        10: assign disp_data = ;
        11: assign disp_data = ;
        12: assign disp_data = ;
        13: assign disp_data = ;
        14: assign disp_data = ;
        15: assign disp_data = ;
    endcase
    clk_div U_clk_div(.clk(Clock),.rst(Reset),.SW15(sw_i[15]),.Clk_CPU(clk));
    PcUnit U_pcUnit(.PC(pcOut),.PcReSet(Reset),.PcSel(pcSel),.Adress(extDataOut),.Jump(jump),.Jumpaddr(jumpaddr)
                    ,.clk(clk),.pause(sw_i[14]));
    IMem U_IMem(.a(imAdr),.spo(opCode));
    seg7x16 U_seg7x16(.clk(Clock),.reset(Reset),.i_data(disp_data),.o_seg(o_seg),.o_sel(o_sel));
    GPR U_gpr(.DataOut1(gprDataOut1),.DataOut2(gprDataOut2),.clk(clk),.WData(gprDataIn)
              ,.WE(RegW),.WeSel(gprWeSel),.ReSel1(gprReSel1),.ReSel2(gprReSel2));
    Ctrl U_Ctrl(.jump(jump),.RegDst(RegDst),.Branch(Branch),.MemR(MemR),.Mem2R(Mem2R)
                ,.MemW(MemW),.RegW(RegW),.Alusrc(Alusrc),.ExtOp(ExtOp),.Aluctrl(Aluctrl)
                ,.OpCode(op),.funct(funct));
    Extender U_extend(.ExtOut(extDataOut),.DataIn(extDataIn),.ExtOp(ExtOp));
    Alu U_Alu(.AluResult(aluDataOut),.Zero(zero),.DataIn1(gprDataOut1),.DataIn2(aluDataIn2),.Shamt(opCode[10:6]),.AluCtrl(Aluctrl));
    DMem U_DMem(.DataOut(dmDataOut),.DataAdr(dmDataAdr),.DataIn(gprDataOut2),.DMemW(MemW),.DMemR(MemR),.clk(clk));
endmodule