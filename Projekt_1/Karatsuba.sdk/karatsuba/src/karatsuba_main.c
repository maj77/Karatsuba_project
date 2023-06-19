/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "karatsuba_AXI_IP.h"
#include "xparameters.h"
#include "xil_io.h"
#include "sleep.h"
#include <inttypes.h>
#include "xuartps.h"
#include <math.h>
#include <string.h>

#define A_LOW KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG0_OFFSET
#define A_HIGH KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG1_OFFSET
#define B_HIGH KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG2_OFFSET
#define B_LOW KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG3_OFFSET
#define RESULT_0 KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG4_OFFSET
#define RESULT_1 KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG5_OFFSET
#define RESULT_2 KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG6_OFFSET
#define RESULT_3 KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG7_OFFSET
#define REG8 KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG8_OFFSET
#define STATUS_REG KARATSUBA_AXI_IP_S_AXI_KARA_SLV_REG9_OFFSET
#define BASEADDR XPAR_KARATSUBA_AXI_IP_0_S_AXI_KARA_BASEADDR
#define UART_ID XPAR_PS7_UART_1_DEVICE_ID
#define UART_BASEADDR XPAR_PS7_UART_1_BASEADDR

#define STATUS_REG_MASK 0x1


/**
 * Function reads 8 bytes from uart
 */
u64 read_data_in(){
	u64 ret = 0;
	char8 c;
	int received_chars = 0;
	char8 my_array[20] = {'\0'};

	    while ((c = inbyte()) != '\n') {
	    	if(c != '\r'){
	    		my_array[received_chars++] = c;
	    	}else{
	    		break;
	    	}
	    }

	    for(u8 i = 0; i < received_chars; i++) {
	    	u64 temp = (u64)pow(10, i);
	    	u8 temp_val = (my_array[received_chars-1-i] - '0');
	        ret += temp_val * temp;
	    }

	    return ret;
}


int main()
{
    init_platform();

    u64 A = 0; //35452834763297432;
    u64 B = 0; //35452834763297432;
    u32 res0 = 0;
    u32 res1 = 0;
    u32 res2 = 0;
    u32 res3 = 0;

    while(1){
    	//--------------- read input data from uart ---------------
    	A = read_data_in();
    	B = read_data_in();

    	printf("A =  %llu\n", A);
    	printf("B =  %llu\n", B);
    	printf("A =  0x%08llx\n", A);
    	printf("B =  0x%08llx\n", B);

    	//--------------- write input data to Karatsuba registers ---------------
    	KARATSUBA_AXI_IP_mWriteReg(BASEADDR, A_LOW, (u32)A);
    	KARATSUBA_AXI_IP_mWriteReg(BASEADDR, A_HIGH, ((u32)(((A) >> 16) >> 16)));
    	KARATSUBA_AXI_IP_mWriteReg(BASEADDR, B_LOW, (u32)B);
    	KARATSUBA_AXI_IP_mWriteReg(BASEADDR, B_HIGH, ((u32)(((B) >> 16) >> 16)));

    	//--------------- wait for ready flag from status register,  then read results ---------------
    	printf("waiting for results\n\r");
    	while( (KARATSUBA_AXI_IP_mReadReg(BASEADDR, STATUS_REG) & STATUS_REG_MASK) == 0);
    	res0 = KARATSUBA_AXI_IP_mReadReg(BASEADDR, RESULT_0);
    	res1 = KARATSUBA_AXI_IP_mReadReg(BASEADDR, RESULT_1);
    	res2 = KARATSUBA_AXI_IP_mReadReg(BASEADDR, RESULT_2);
    	res3 = KARATSUBA_AXI_IP_mReadReg(BASEADDR, RESULT_3);
    	printf("results received\n\r");

    	//--------------- print contents of result registers ---------------
    	printf("res3 =  0x%08lx\n", (u32)res3);
    	printf("res2 =  0x%08lx\n", (u32)res2);
    	printf("res1 =  0x%08lx\n", (u32)res1);
    	printf("res0 =  0x%08lx\n", (u32)res0);

    	//--------------- print result (send it to uart) ---------------
    	printf("result:");
    	printf("%08lx", (u32)res3);
    	printf("%08lx", (u32)res2);
    	printf("%08lx", (u32)res1);
    	printf("%08lx\n", (u32)res0);
   }
    cleanup_platform();
    return 0;
}
