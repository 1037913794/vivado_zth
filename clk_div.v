//`timescale 1ns / 1ps
module clk_div( input clk,
                input rst,
                input SW15,
                output Clk_CPU
              );

// Clock divider-ʱ�ӷ�Ƶ��

  reg[31:0]clkdiv;

  always @ (posedge clk or posedge rst) begin 
    if (rst) clkdiv <= 0; else clkdiv <= clkdiv + 1'b1; end
//������ã���clkdivΪ0������ÿ��ʱ������clkdiv����
  assign Clk_CPU=(SW15)? clkdiv[25] : clkdiv[18];
//assign Clk_CPU= clkdiv[8]; 
//��sw15Ϊ1����ʱ���źŷ���128��
endmodule
