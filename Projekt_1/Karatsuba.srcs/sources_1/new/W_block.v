`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2023 18:13:48
// Module Name: U_block
// Description: Module calculates (AH-AL)*(BH-BL)
////////////////////////////////////////////////////////////////////////////////////


module W_block#( parameter IN_WIDTH  = 33, // + one padding bit which is not included
                 parameter OUT_WIDTH = 68
              )( 
                 input                  clk,
                 input                  rst,
                 input  [ IN_WIDTH-1:0] A, //[32:0]
                 input  [ IN_WIDTH-1:0] B,
                 output [OUT_WIDTH-1:0] result 
               );
// module performs 33b*33b multiplication, but inside it's implemented as 34*34b so shifts are power of 2
reg  [  IN_WIDTH/2:0] AH_r; //[16:0]
reg  [  IN_WIDTH/2:0] AL_r; //[16:0]
reg  [  IN_WIDTH/2:0] BH_r; //[16:0]
reg  [  IN_WIDTH/2:0] BL_r; //[16:0]               
wire [IN_WIDTH/2+1:0] A_sum; //[17:0]
wire [IN_WIDTH/2+1:0] B_sum; //[17:0]
wire [    IN_WIDTH:0] U; //[33:0]
wire [    IN_WIDTH:0] V; //[33:0]
wire [  IN_WIDTH+1:0] W; //[34:0]
wire [  IN_WIDTH+1:0] Z; //[34:0]
reg  [ OUT_WIDTH-1:0] res_r;


always@(posedge clk)
begin
  AH_r <= A[IN_WIDTH-1:IN_WIDTH/2+1]; // verilog should automatically add one MSB bit equal to 0
  AL_r <= A[           IN_WIDTH/2:0];
  BH_r <= B[IN_WIDTH-1:IN_WIDTH/2+1];
  BL_r <= B[           IN_WIDTH/2:0];
end

assign A_sum = AH_r + AL_r;
assign B_sum = BH_r + BL_r;


mult_17b mult_U_i (//.CLK(clk ),
                   .A  (AH_r),
                   .B  (BH_r),
                   .P  (U   )
                  );

mult_17b mult_V_i (//.CLK(clk ),
                   .A  (AL_r),
                   .B  (BL_r),
                   .P  (V   )
                  );

mult_18b mult_W_i (//.CLK(clk   ),
                   .A  (A_sum ),
                   .B  (B_sum ),
                   .P  (W     )
                  );
//assign W = A_sum*B_sum;

assign Z = W - U - V;

always@*
begin
  res_r = (U<<34) + (Z<<17) + V;
end

assign result = res_r; 

endmodule
