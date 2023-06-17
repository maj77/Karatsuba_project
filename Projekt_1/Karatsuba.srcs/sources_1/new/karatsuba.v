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
                   input                  data_vld_i,
                   output [OUT_WIDTH-1:0] C_o,
                   output                 data_vld_o
                  );


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
wire [  IN_WIDTH/2:0] B_sum;

// ----output values----
wire [  IN_WIDTH-1:0] U;
wire [  IN_WIDTH-1:0] V;
wire [    IN_WIDTH:0] W; //64
wire [    IN_WIDTH:0] Z;
wire [  IN_WIDTH-1:0] Z_abs;
reg  [ OUT_WIDTH-1:0] result;
reg  [           2:0] din_vld_r;
reg  [           2:0] dout_vld_r;
wire [           2:0] dout_vld;

always@(posedge clk) // consider register here
begin
  if (data_vld_i) begin
    A_r       <= A_i;
    B_r       <= B_i;
    din_vld_r <= {3{data_vld_i}};
  end
end

assign AH = A_r[IN_WIDTH-1:IN_WIDTH/2];
assign AL = A_r[       IN_WIDTH/2-1:0];
assign BH = B_r[IN_WIDTH-1:IN_WIDTH/2];
assign BL = B_r[       IN_WIDTH/2-1:0];

assign A_sum = AH + AL;
assign B_sum = BH + BL;
              

// U and V blocks take 32bit input values,
// W block takes 33 bit input value
// A_H * B_H
U_block u_i ( .clk    (clk         ),
              .rst    (rst         ),
              .A      (AH          ),
              .B      (BH          ),
              .vld_in (din_vld_r[0]),
              .result (U           ),
              .vld_out(dout_vld[0] )  
             );
              
// A_L * B_L
V_block v_i ( .clk    (clk         ),
              .rst    (rst         ),
              .A      (AL          ),
              .B      (BL          ),
              .vld_in (din_vld_r[1]),
              .result (V           ),
              .vld_out(dout_vld[1] )   
             );

//(A_H + A_L) * (B_H + B_L)
W_block w_i ( .clk    (clk         ),
              .rst    (rst         ),
              .A      (A_sum       ),
              .B      (B_sum       ),
              .vld_in (din_vld_r[2]),
              .result (W           ),
              .vld_out(dout_vld[2] )
             );


assign Z = W - U - V;

always@(posedge clk)
begin
  result     <= (U<<64) + (Z<<32) + V;
  dout_vld_r <= dout_vld;
end

assign C_o        = result;
assign data_vld_o = &dout_vld_r;

endmodule
