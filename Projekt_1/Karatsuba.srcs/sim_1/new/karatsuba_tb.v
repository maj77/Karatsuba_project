`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.05.2023 18:51:37
// Design Name: 
// Module Name: karatsuba_tb
// Project Name: 
// Target Devices: 
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


module karatsuba_tb();
localparam TESTS_COUNT = 50;

reg          clk;
reg          res_check_clk;
reg          rst;
reg  [63:0]  A, A_tb;
reg  [63:0]  B, B_tb;
wire [127:0] result;
reg  [127:0] result_check, result_check_buf;
reg  [63:0]  test_array[2*TESTS_COUNT-1:0];
reg  [31:0]  A_test, B_test;
wire [63:0]  V_test;

karatsuba karatsuba_i ( .clk(clk   ),
                        .rst(rst   ),
                        .A_i(A     ),
                        .B_i(B     ),
                        .C_o(result) );
// +--------------------------------------------+
// |                 sandbox                    |
// +--------------------------------------------+
/*
wire [31:0] wb_a, wb_b, vb_a, vb_b, ub_a, ub_b;
wire [63:0] wb_res, vb_res, ub_res;
// A_H * B_H
assign ub_a = 32'h113018e2;
assign ub_b = 32'hc024d702;
// B_H * B_L
assign vb_a = 32'hf0c26c41;
assign vb_b = 32'h7c74b1bf;
//(A_H + A_L) * (B_H + B_L)
assign wb_a = 32'h113018e2 + 32'hc024d702; // A_H + A_L
assign wb_b = 32'hf0c26c41 + 32'h7c74b1bf; // B_H + B_L

assign wb_res = wb_a * wb_b;
assign vb_res = vb_a * vb_b;
assign ub_res = ub_a * ub_b;
*/
                       
// +--------------------------------------------+
// |                 CLOCKS                     |
// +--------------------------------------------+

//main clock
initial
 clk <= 1'b1;
always
 #5 clk <= ~clk;
 
// result check clock
initial begin
  res_check_clk <= 1'b0;
  #45 res_check_clk <= 1'b1;
  forever begin
    #5 res_check_clk <= 1'b0;
    #15 res_check_clk <= 1'b1;
  end
end

// +--------------------------------------------+
// | LOAD TESTVECTOR FROM FILE TO REG version2  |
// +--------------------------------------------+
initial begin
  // functuon automatically reads file and stores its content in array, last letter 'h' in function name says that it will be stored as hex values
  $readmemh("D:/Studia_EiT/magisterskie/Semestr_I/Systemy_dedykowane_w_ukladach_programowalnych/Projekt_1/test_vectors.txt", test_array);
end


// +--------------------------------------------+
// |                 Setup signas               |
// +--------------------------------------------+
//Reset signal
initial
begin
 rst <= 1'b1;
 #10 rst <= 1'b0;
end 

initial
  $timeformat(-9, 2, " ns", 20);


// +--------------------------------------------+
// |            Apply TV to input               |
// +--------------------------------------------+
integer i;
initial
begin
  for(i=0; i<TESTS_COUNT; i=i+2) begin
    #20
    A <= test_array[i];
    B <= test_array[i+1];
  end
  #20 $fclose(log_file_handler); $finish;
end

assign V_test = A_test*B_test;

// +--------------------------------------------+
// |            Result check                    |
// +--------------------------------------------+
always@(posedge clk)
begin
    A_tb <= A;
    B_tb <= B; 
end

always@(posedge clk)
begin
    result_check_buf <= A_tb*B_tb;
    result_check     <= result_check_buf; 
end

integer incorrect_results = 0;
integer correct_results = 0;
integer log_file_handler;
initial log_file_handler = $fopen("D:/Studia_EiT/magisterskie/Semestr_I/Systemy_dedykowane_w_ukladach_programowalnych/Projekt_1/simulation_logs.txt", "w");

// TODO: add saving logs to file
always@(posedge res_check_clk)
begin
    //|---------------------------------------------------------------------------------------|
    //|--------------------------------- PRINT LOGS ------------------------------------------|
    //|---------------------------------------------------------------------------------------|
    $strobe("----------------------------------------------------------------------");
    if(result !== result_check) begin
        incorrect_results = incorrect_results + 1;
        $strobe("time: %0t", $time);
        $strobe("INCORRECT RESULT!\nA=   %h, B=   %h \t\t   A_tb=%h, B_tb=%h ", A, B, A_tb, B_tb);
        $strobe("result : %h", result);
        $strobe("r_check: %h", result_check);
    end else begin
        correct_results = correct_results + 1;
        $strobe("time: %0t", $time);
        $strobe("CORRECT RESULT!\nA=   %h, B=   %h \t\t   A_tb=%h, B_tb=%h ", A, B, A_tb, B_tb);
        $strobe("result : %h     ", result);
        $strobe("r_check: %h", result_check);
    end
    $strobe("\nResults summary: \nCorrect: %d,\nIncorrect: %d\n", correct_results, incorrect_results);
    $strobe("----------------------------------------------------------------------");
    
    
    //|---------------------------------------------------------------------------------------|
    //|--------------------------------- WRITE LOGS TO FILE  ---------------------------------|
    //|---------------------------------------------------------------------------------------|
    $fwrite(log_file_handler, "----------------------------------------------------------------------\n");
    if(result !== result_check) begin
        $fwrite(log_file_handler,"time: %0t\n", $time);
        $fwrite(log_file_handler,"INCORRECT RESULT!\nA=   %h, B=   %h \nA_tb=%h, B_tb=%h\n", A, B, A_tb, B_tb);
        $fwrite(log_file_handler,"result : %h\n", result);
        $fwrite(log_file_handler,"r_check: %h\n", result_check);
    end else begin
        $fwrite(log_file_handler,"time: %0t\n", $time);
        $fwrite(log_file_handler,"CORRECT RESULT!\nA=   %h, B=   %h \nA_tb=%h, B_tb=%h\n", A, B, A_tb, B_tb);
        $fwrite(log_file_handler,"result : %h\n", result);
        $fwrite(log_file_handler,"r_check: %h\n", result_check);
    end
    $fwrite(log_file_handler, "\nResults summary: \nCorrect: %d,\nIncorrect: %d\n", correct_results, incorrect_results);
    $fwrite(log_file_handler, "----------------------------------------------------------------------");
    
end

endmodule
