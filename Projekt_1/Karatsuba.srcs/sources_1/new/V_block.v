`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2023 18:13:48
// Module Name: U_block
// Description: Module calculates AL*BL
////////////////////////////////////////////////////////////////////////////////////


module V_block#( parameter IN_WIDTH  = 32,
                 parameter OUT_WIDTH = 64
              )( 
                 input                  clk,
                 input                  rst,
                 input  [IN_WIDTH-1:0]  A,
                 input  [IN_WIDTH-1:0]  B,
                 output [OUT_WIDTH-1:0] AtB
                );

reg  [IN_WIDTH/2-1:0] ABH_r;
reg  [IN_WIDTH/2-1:0] ABL_r;
reg  [IN_WIDTH/2-1:0] BBH_r;
reg  [IN_WIDTH/2-1:0] BBL_r;
wire [  IN_WIDTH/2:0] A_sum;
wire [  IN_WIDTH/2:0] B_sum;
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [  IN_WIDTH+1:0] W_temp;
reg  [  IN_WIDTH-1:0] W;
reg  [  IN_WIDTH-1:0] Z; 
wire [ OUT_WIDTH-1:0] res_test;

always@(posedge clk)
begin
  ABH_r <= A[IN_WIDTH-1:IN_WIDTH/2];
  ABL_r <= A[       IN_WIDTH/2-1:0];
  BBH_r <= B[IN_WIDTH-1:IN_WIDTH/2];
  BBL_r <= B[       IN_WIDTH/2-1:0];
end
 
assign A_sum = ABH_r + ABL_r;    
assign B_sum = BBH_r + BBL_r;
              
mult_gen_0 mult_U_i (.clk(clk  ),
                     .A  (ABH_r),
                     .B  (BBH_r),
                     .P  (U    )
                    );

mult_gen_0 mult_V_i (.clk(clk  ),
                     .A  (ABL_r),
                     .B  (BBL_r),
                     .P  (V    )
                    );
                    
//assign W_temp = A_sum * B_sum;
mult_17b mult_W_i (.clk(clk  ),
                   .A  (A_sum),
                   .B  (B_sum),
                   .P  (W_temp   )
                   );

always@*
begin
  Z = W_temp - U - V;
end

assign AtB = (U<<32) + (Z<<16) + V;

endmodule
