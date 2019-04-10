module Mips(Clk,rstn,sw_i,led_o,o_seg,o_sel);
    input   Clk,rstn;
    input   [15:0]  sw_i;
    output  [7:0]   o_seg,o_sel;
    output reg [15:0]  led_o;
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
    wire        jump;						//指令跳转
    wire        RegDst;						
    wire        Branch;						//分支
    wire        MemR;						//读存储器
    wire        Mem2R;						//数据存储器到寄存器堆
    wire        MemW;						//写数据存储器
    wire        RegW;						//寄存器堆写入数据
    wire        Alusrc;						//运算器操作数选择
    wire [1:0]  ExtOp;						//位扩展器符号扩展选择
    wire [4:0]  Aluctrl;					//Alu运算选择
//Alu
    wire [31:0] aluDataIn2;
    wire [31:0]	aluDataOut;
    wire        zero;
//Other
    wire        pcSel;
    wire        divided_clk;                        //分频后的信号
    reg  [31:0] disp_data;
    wire        Reset;
    wire [31:0] disp_mem;
    assign Reset = ~rstn;
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
    //13:数码管显示控制位
    //12:控制指令显示控制位
    //11-8:数码管显示内容选择位
    //7-0:内存地址位(共256个存储单元)
    always @(*)
    begin
        if(sw_i[12])
        begin
            led_o[15] = divided_clk;
            led_o[14] = ExtOp[1];
            led_o[13] = ExtOp[0];
            led_o[12] = Aluctrl[4];
            led_o[11] = Aluctrl[3];
            led_o[10] = Aluctrl[2];
            led_o[9] = Aluctrl[1];
            led_o[8] = Aluctrl[0];
            led_o[7] = jump;
            led_o[6] = RegDst;
            led_o[5] = Branch;
            led_o[4] = MemR;
            led_o[3] = Mem2R;
            led_o[2] = MemW;
            led_o[1] = RegW;
            led_o[0] = Alusrc;
        end
        else
            led_o = sw_i;
        if(sw_i[13])
            case(sw_i[11:8])
                0 : disp_data = (RegW)?gprDataIn:((MemW)?gprDataOut2:pcOut);
                1 : disp_data = disp_mem;
                2 : disp_data = pcOut;
                3 : disp_data = opCode;
                4 : disp_data = gprDataOut1;
                5 : disp_data = gprDataOut2;
                6 : disp_data = gprDataIn;
                7 : disp_data = {27'd0,gprReSel1};
                8 : disp_data = {27'd0,gprReSel2};
                9 : disp_data = {27'd0,gprWeSel};
                10: disp_data = {16'd0,extDataIn};
                11: disp_data = extDataOut;
                12: disp_data = gprDataOut1;
                13: disp_data = aluDataIn2;
                14: disp_data = aluDataOut;
                15: disp_data = dmDataOut;
            endcase
        else
            disp_data = (RegW)?gprDataIn:((MemW)?gprDataOut2:pcOut);
    end
    clk_div U_clk_div(.clk(Clk),.rst(Reset),.SW15(sw_i[15]),.Clk_CPU(divided_clk));
    PcUnit U_pcUnit(.PC(pcOut),.PcReSet(Reset),.PcSel(pcSel),.Adress(extDataOut),.Jump(jump),.Jumpaddr(jumpaddr)
                    ,.clk(divided_clk),.pause(sw_i[14]));
    IMem U_IMem(.a(imAdr),.spo(opCode));
    seg7x16 U_seg7x16(.clk(Clk),.reset(Reset),.i_data(disp_data),.o_seg(o_seg),.o_sel(o_sel));
    GPR U_gpr(.DataOut1(gprDataOut1),.DataOut2(gprDataOut2),.clk(divided_clk),.WData(gprDataIn)
              ,.WE(RegW),.WeSel(gprWeSel),.ReSel1(gprReSel1),.ReSel2(gprReSel2));
    Ctrl U_Ctrl(.jump(jump),.RegDst(RegDst),.Branch(Branch),.MemR(MemR),.Mem2R(Mem2R)
                ,.MemW(MemW),.RegW(RegW),.Alusrc(Alusrc),.ExtOp(ExtOp),.Aluctrl(Aluctrl)
                ,.OpCode(op),.funct(funct));
    Extender U_extend(.ExtOut(extDataOut),.DataIn(extDataIn),.ExtOp(ExtOp));
    Alu U_Alu(.AluResult(aluDataOut),.Zero(zero),.DataIn1(gprDataOut1),.DataIn2(aluDataIn2),.Shamt(opCode[10:6]),.AluCtrl(Aluctrl));
    DMem U_DMem(.DataOut(dmDataOut),.DataAdr(dmDataAdr),.DataIn(gprDataOut2),.DMemW(MemW),.DMemR(MemR),.clk(divided_clk),.sel(sw_i[7:0]),.disp(disp_mem));
endmodule