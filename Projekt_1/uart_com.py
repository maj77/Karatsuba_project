import serial
import random
from tabulate import tabulate


#####################################################################################
class PrintColor:
    GREEN = '\033[92m'
    ORANGE = '\033[93m'
    RED = '\033[91m'
    ENDC = '\033[0m'

def write_uart(num):
    for digit in num:
        my_serial.write(digit.encode())
    my_serial.write('\n'.encode())

def rand_num_gen():
    rand_num = random.randrange(2**64)
    return rand_num


#####################################################################################


my_serial = serial.Serial("COM7", 115200)

value = str()
matches = 0
missmatches = 0
loop_limit = 10
i = 0

result_checked = 1
while True:
    
    if (result_checked == 1):
        print("-------- generating new inputs --------")
        a = rand_num_gen()
        b = rand_num_gen()
        c = a*b
        write_uart(str(a))
        write_uart(str(b))
    result_checked = 0
    
    value = my_serial.readline().decode('utf-8')
    print("Received from uart:", value.strip())

    if value.startswith("result:"):
        result_checked = 1
        i = i + 1
        result = value[7:] # cut 'result:' from result string

        if (int(result, 16) == c):
            matches = matches + 1
            result = "0x"+result
            print(f'{PrintColor.GREEN}RESULT MATCH, total matches: {matches}{PrintColor.ENDC}')
            print(f'{PrintColor.GREEN} received: {result.strip()}{PrintColor.ENDC}')
            print(f'{PrintColor.GREEN} expected: {hex(c)}{PrintColor.ENDC}')
            #print("received ", result.strip())
            #print("expected ", hex(c))
        else:
            missmatches = missmatches + 1
            result = "0x"+result
            print(f'{PrintColor.RED}RESULT MISSMATCH, total missmatches: {missmatches}{PrintColor.ENDC}')
            print("received ", result.strip())
            print("expected ", hex(c))
    
    if(i == loop_limit): 
        print(tabulate([["total matches","total missmatches"],[matches,missmatches]],["results",""], tablefmt="grid"))
        print("")
        break

#####################################################################################