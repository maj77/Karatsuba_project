`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: AGH
// Engineer: Marcin Maj
// 
// Create Date: 03.05.2023 17:40:32
// Design Name: 
// Module Name: karatsuba
// Project Name: FPGA implementation of karatsuba multiplication algorithm
// Target Devices: ZYNQ-7000
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module karatsuba#( parameter IN_WIDTH = 64,
                   parameter OUT_WIDTH = IN_WIDTH*2
                )( 
                   input                  clk,
                   input                  rst,
                   input  [ IN_WIDTH-1:0] A_i,
                   input  [ IN_WIDTH-1:0] B_i,
                   output [OUT_WIDTH-1:0] C_o 
                  );


//TODO: zrobiæ mniej sygna³ów ale szersze, np zamiast AAH, AAL zrobic jeden sygnal i w submodule to rozdzielic
//      wydaje mi sie ze bedzie to latwiejsze w debugowaniu
// ----------internal signals---------------
// ----input values----
reg [   IN_WIDTH-1:0] A_r;
reg [   IN_WIDTH-1:0] B_r;

// fist stage split n/2
wire [IN_WIDTH/2-1:0] AH;
wire [IN_WIDTH/2-1:0] AL;
wire [IN_WIDTH/2-1:0] BH;
wire [IN_WIDTH/2-1:0] BL;
wire [  IN_WIDTH/2:0] A_sum;
wire [  IN_WIDTH/2:0] B_sum;  // dodatkowy bit bo suma

// ----output values----
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [  IN_WIDTH-1:0] W;
reg  [  IN_WIDTH-1:0] Z;
wire [  IN_WIDTH-1:0] Z_abs;
wire [ OUT_WIDTH-1:0] result;



always@*
begin
  A_r <= A_i;
  B_r <= B_i;
end

assign AH = A_r[IN_WIDTH-1:IN_WIDTH/2]; //[63:32];
assign AL = A_r[       IN_WIDTH/2-1:0];//[31:0];
assign BH = B_r[IN_WIDTH-1:IN_WIDTH/2]; //[63:32];
assign BL = B_r[       IN_WIDTH/2-1:0];//[31:0];

assign A_sum = AH + AL;
assign B_sum = BH + BL;
              

// U and V blocks take 32bit input values,
// W block take 33 bit input value
// A_H * B_H
U_block u_i ( .clk   (clk),
              .rst   (rst),
              .A     (AH ),
              .B     (BH ),
              .result(U  )  );
              
// A_L * B_L
V_block v_i ( .clk   (clk),
              .rst   (rst),
              .A     (AL ),
              .B     (BL ),
              .result(V  )   );

//(A_H + A_L) * (B_H + B_L)
W_block w_i ( .clk   (clk  ),
              .rst   (rst  ),
              .A     (A_sum),
              .B     (B_sum),
              .result(W    ) );
      
always@*
begin
  Z = W - U - V;
end

assign C_o = (U<<64) + (Z<<32) + V;

endmodule
