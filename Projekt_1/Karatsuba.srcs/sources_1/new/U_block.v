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
                 output [OUT_WIDTH-1:0] AtB 
               );
                  
reg  [IN_WIDTH/2-1:0] AAH_r;
reg  [IN_WIDTH/2-1:0] AAL_r;
reg  [IN_WIDTH/2-1:0] BAH_r;
reg  [IN_WIDTH/2-1:0] BAL_r;
wire [  IN_WIDTH/2:0] A_sum;
wire [  IN_WIDTH/2:0] B_sum;
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [  IN_WIDTH+1:0] W_temp;
reg  [  IN_WIDTH-1:0] W;
reg  [  IN_WIDTH-1:0] Z;
wire [  IN_WIDTH-1:0] Z_abs;
wire [ OUT_WIDTH-1:0] mult_result;


always@(posedge clk)
begin
  AAH_r <= A[IN_WIDTH-1:IN_WIDTH/2];
  AAL_r <= A[       IN_WIDTH/2-1:0];
  BAH_r <= B[IN_WIDTH-1:IN_WIDTH/2];
  BAL_r <= B[       IN_WIDTH/2-1:0];
end

assign A_sum = AAH_r + AAL_r;
assign B_sum = BAH_r + BAL_r;

mult_gen_0 mult_U_i (.clk(clk  ),
                     .A  (AAH_r),
                     .B  (BAH_r),
                     .P  (U    )
                    );

mult_gen_0 mult_V_i (.clk(clk  ),
                     .A  (AAL_r),
                     .B  (BAL_r),
                     .P  (V    )
                    );
                    
mult_17b mult_W_i (.clk(clk      ),
                   .A  (A_sum    ),
                   .B  (B_sum    ),
                   .P  (W_temp   )
                  );

always@*
begin
  Z = W_temp - U - V;
end

assign AtB = (U<<32) + (Z<<16) + V;

endmodule
