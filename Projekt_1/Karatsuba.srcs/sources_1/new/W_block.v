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
                 input                 clk,
                 input                 rst,
                 input  [ IN_WIDTH-1:0] A,
                 input  [ IN_WIDTH-1:0] B,
                 output [OUT_WIDTH-1:0] result 
               );
    
reg  [  IN_WIDTH/2:0] AH_r;
reg  [  IN_WIDTH/2:0] AL_r;
reg  [  IN_WIDTH/2:0] BH_r;
reg  [  IN_WIDTH/2:0] BL_r;               
wire [IN_WIDTH/2+1:0] A_sum;
wire [IN_WIDTH/2+1:0] B_sum;
wire [IN_WIDTH-1:0] U;
wire [IN_WIDTH-1:0] V;
wire [IN_WIDTH+1:0] W_temp;
reg  [IN_WIDTH-1:0] W;
reg  [IN_WIDTH-1:0] Z;
wire [IN_WIDTH-1:0] Z_abs;
wire [ OUT_WIDTH-1:0] mult_result;

always@(posedge clk)
begin
  AH_r <= A[IN_WIDTH-1:IN_WIDTH/2+1];
  AL_r <= A[           IN_WIDTH/2:0];
  BH_r <= B[IN_WIDTH-1:IN_WIDTH/2+1];
  BL_r <= B[           IN_WIDTH/2:0];
end

assign A_sum = AH_r + AL_r;
assign B_sum = BH_r + BL_r;

mult_17b mult_U_i (.clk(clk  ),
                   .A  (AH_r),
                   .B  (BH_r),
                   .P  (U    )
                  );

mult_17b mult_V_i (.clk(clk  ),
                   .A  (AL_r),
                   .B  (BL_r),
                   .P  (V    )
                  );

mult_18b mult_W_i (.clk(clk      ),
                   .A  (A_sum    ),
                   .B  (B_sum    ),
                   .P  (W_temp   )
                  );

always@*
begin
  Z = W_temp - U - V;
end

assign result = (U<<34) + (Z<<17) + V; // prawdopodobnie trzeba bedzie shift zwiekszyc bo mamy na wejsciu 17 bitowe wartosci

endmodule
