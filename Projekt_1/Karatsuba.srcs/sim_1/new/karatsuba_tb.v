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

localparam TESTS_COUNT = 500;

reg          clk;
reg          res_check_clk;
reg          rst;
reg  [63:0]  A, A_tb;
reg  [63:0]  B, B_tb;
wire [127:0] result;
reg  [127:0] result_check, result_check_buf, result_check_buf2;
reg  [63:0]  test_array[2*TESTS_COUNT-1:0];
//--------------- debug signals ---------------
wire [32:0]  Aw_test, Bw_test;
wire [65:0]  W_test;
wire [31:0]  Au_test, Bu_test, Av_test, Bv_test;
wire [63:0]  U_test, V_test;
//---------------- W block debug signals ------------------
wire [16:0] AH, AL, BH, BL;
wire [17:0] A_sum, B_sum;
wire [33:0] wb_u, wb_v;
wire [34:0] wb_z;
wire [34:0] wb_w; 
wire [67:0] wb_res;


karatsuba karatsuba_i ( .clk(clk   ),
                        .rst(rst   ),
                        .A_i(A     ),
                        .B_i(B     ),
                        .C_o(result) );

// +--------------------------------------------+
// |                 sandbox                    |
// +--------------------------------------------+
assign Aw_test = 33'h1c232c05f; 
assign Bw_test = 33'h168b33228;
assign W_test = Aw_test * Bw_test;

assign Au_test = 32'hd8089c97;
assign Bu_test = 32'h9b95f2fb;
assign U_test  = Au_test * Bu_test;

assign Av_test = 32'hea2a23c8;
assign Bv_test = 32'hcd1d3f2d;
assign V_test  = Av_test * Bv_test;

assign AH = 17'h0b28e;
assign AL = 17'h1ebba;
assign BH = 17'h06601;
assign BL = 17'h1f601;
assign wb_u = AH*BH;
assign wb_v = AL*BL;
assign A_sum = AH+AL;
assign B_sum = BH+BL;
assign wb_w = A_sum*B_sum;
assign wb_z = wb_w - wb_u - wb_v;
assign wb_res = (wb_u<<34) + (wb_z<<17) + wb_v;


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
    #5  res_check_clk <= 1'b0;
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
`define TV_ON

integer i;
initial
begin
`ifdef TV_ON
  for(i=0; i<TESTS_COUNT; i=i+2) begin
    #20
    A = test_array[i];
    B = test_array[i+1];
    $strobe("i = %d", i);
  end
`else
    A = 64'hd8089c97ea2a23c8;
    B = 64'h9b95f2fbcd1d3f2d;
    #60
`endif
  #20 $fclose(log_file_handler); $finish;
end



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
    //result_check_buf2 <= result_check_buf;
    result_check      <= result_check_buf; 
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
        $strobe("diff   : %h", result_check^result);
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
    //$fwrite(log_file_handler, "----------------------------------------------------------------------\n");
    if(result !== result_check) begin
        $fwrite(log_file_handler,"time: %0t\n", $time);
        $fwrite(log_file_handler,"INCORRECT RESULT!\nA=   %h, B=   %h \nA_tb=%h, B_tb=%h\n", A, B, A_tb, B_tb);
        $fwrite(log_file_handler,"result : %h\n", result);
        $fwrite(log_file_handler,"r_check: %h\n", result_check);
        $fwrite(log_file_handler,"diff   : %h\n", result_check^result);
        $fwrite(log_file_handler, "\nResults summary: \nCorrect: %d,\nIncorrect: %d\n", correct_results, incorrect_results);
        $fwrite(log_file_handler, "----------------------------------------------------------------------\n");
    end else begin
    //    $fwrite(log_file_handler,"time: %0t\n", $time);
    //    $fwrite(log_file_handler,"CORRECT RESULT!\nA=   %h, B=   %h \nA_tb=%h, B_tb=%h\n", A, B, A_tb, B_tb);
    //    $fwrite(log_file_handler,"result : %h\n", result);
    //    $fwrite(log_file_handler,"r_check: %h\n", result_check);
    end
end

endmodule
