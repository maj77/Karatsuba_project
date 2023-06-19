# Karatsuba_project
Hardware implementation of Karatsuba multiplication algorithm.
---
Project consist of Karatsuba algorithm implemented in Verilog, testbench, ARM processor which communicates with Karatsuba IP over AXI Lite interface, python scripts used for generating test values and communication with board over uart.

Project was implemented and run on Zybo board

![karatsuba_AXI_IP](https://github.com/maj77/Karatsuba_project/assets/38226349/95ddec96-8038-459c-a628-68c46d87cf79)

---
## Python UART script demo
_uart_com.py_ tests if system is working correctly by sending data to board and then comparing results
 ![image](https://github.com/maj77/Karatsuba_project/assets/38226349/9299ee81-8d94-4a7e-aa3a-115e4b4e4c85)
