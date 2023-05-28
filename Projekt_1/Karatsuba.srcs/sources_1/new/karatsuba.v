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
reg [IN_WIDTH-1:0] A_r;
reg [IN_WIDTH-1:0] B_r;
// fist stage split n/2
wire [IN_WIDTH/2-1:0] AH;
wire [IN_WIDTH/2-1:0] AL;
wire [IN_WIDTH/2-1:0] BH;
wire [IN_WIDTH/2-1:0] BL;
wire [  IN_WIDTH/2:0] A_sum;
wire [  IN_WIDTH/2:0] B_sum;  // dodatkowy bit bo suma

// second stage split (n/2)/2
wire [IN_WIDTH/4-1:0] AAH;
wire [IN_WIDTH/4-1:0] AAL;
wire [IN_WIDTH/4-1:0] ABH;
wire [IN_WIDTH/4-1:0] ABL; 
wire [IN_WIDTH/4-1:0] BAH;
wire [IN_WIDTH/4-1:0] BAL;
wire [IN_WIDTH/4-1:0] BBH;
wire [IN_WIDTH/4-1:0] BBL;
wire [  IN_WIDTH/4:0] AH_sum; // tutaj bedzie padding o 1 bit zeby bylo po równo
wire [  IN_WIDTH/4:0] AL_sum;
wire [  IN_WIDTH/4:0] BH_sum;
wire [  IN_WIDTH/4:0] BL_sum;
// ----output values----
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [  IN_WIDTH-1:0] W_temp;
reg  [  IN_WIDTH-1:0] W;
reg  [  IN_WIDTH-1:0] Z;
wire [  IN_WIDTH-1:0] Z_abs;
wire [ OUT_WIDTH-1:0] result;



always@*
begin
  A_r <= A_i;
  B_r <= B_i;
end

assign AH = A_r[63:32];
assign AL = A_r[31:0];
assign BH = B_r[63:32];
assign BL = B_r[31:0];

assign A_sum = AH + AL;
assign B_sum = BH + BL;
              
assign AAH    = AH[31:16];   
assign AAL    = AH[15:0];
assign ABH    = AL[31:16];  
assign ABL    = AL[15:0];
assign BAH    = BH[31:16];
assign BAL    = BH[15:0]; 
assign BBH    = BL[31:16];  
assign BBL    = BL[15:0];  
assign AH_sum = A_sum[32:17];
assign AL_sum = A_sum[16:0];
assign BH_sum = B_sum[32:17];
assign BL_sum = B_sum[16:0];

// A_H * B_H
U_block u_i ( .clk(clk),
              .rst(rst),
              .A  (AH ),
              .B  (BH ),
              .AtB(U  )  );
              
// A_L * B_L
V_block v_i ( .clk(clk),
              .rst(rst),
              .A  (AL ),
              .B  (BL ),
              .AtB(V  )   );

//(A_H + A_L) * (B_H + B_L)
W_block w_i ( .clk   (clk   ),
              .rst   (rst   ),
              .A     (A_sum ),
              .B     (B_sum ),
              .result(W_temp) );
      
always@*
begin
  Z = W_temp - U - V;
end

assign C_o = (U<<64) + (Z<<32) + V;

endmodule
