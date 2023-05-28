`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2023 18:13:48
// Module Name: U_block
// Description: Module calculates AH*BH
//////////////////////////////////////////////////////////////////////////////////


module U_block#( parameter IN_WIDTH  = 32,
                 parameter OUT_WIDTH = 64
              )( 
                 input                  clk,
                 input                  rst,
                 input  [ IN_WIDTH-1:0] A,
                 input  [ IN_WIDTH-1:0] B,
                 output [OUT_WIDTH-1:0] result 
               );
                  
reg  [IN_WIDTH/2-1:0] AH_r;
reg  [IN_WIDTH/2-1:0] AL_r;
reg  [IN_WIDTH/2-1:0] BH_r;
reg  [IN_WIDTH/2-1:0] BL_r;
wire [  IN_WIDTH/2:0] A_sum;
wire [  IN_WIDTH/2:0] B_sum;
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [  IN_WIDTH+1:0] W;
reg  [  IN_WIDTH-1:0] Z;


always@(posedge clk)
begin
  AH_r <= A[IN_WIDTH-1:IN_WIDTH/2];
  AL_r <= A[       IN_WIDTH/2-1:0];
  BH_r <= B[IN_WIDTH-1:IN_WIDTH/2];
  BL_r <= B[       IN_WIDTH/2-1:0];
end

assign A_sum = AH_r + AL_r;
assign B_sum = BH_r + BL_r;

mult_gen_0 mult_U_i (.clk(clk ),
                     .A  (AH_r),
                     .B  (BH_r),
                     .P  (U   )
                    );

mult_gen_0 mult_V_i (.clk(clk ),
                     .A  (AL_r),
                     .B  (BL_r),
                     .P  (V   )
                    );
                    
mult_17b mult_W_i (.clk(clk  ),
                   .A  (A_sum),
                   .B  (B_sum),
                   .P  (W    )
                  );

always@*
begin
  Z = W - U - V;
end

assign result = (U<<32) + (Z<<16) + V;

endmodule
