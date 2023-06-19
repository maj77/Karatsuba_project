def karatsuba(num1, num2):
    
    if num1 < 10 or num2 < 10:
        return num1*num2
    else:
       
        m = max(len(str(num1)), len(str(num2)))
        m2 = m//2

        num1_high = num1 // 10**(m2)
        num1_low  = num1 %  10**(m2)
        num2_high = num2 // 10**(m2)
        num2_low  = num2 %  10**(m2)

        v = karatsuba(num1_low, num2_low)
        w = karatsuba((num1_high+num1_low), (num2_high+num2_low))
        u = karatsuba(num1_high, num2_high)

        return (u * 10**(2*m2)) + ((w - u - v) * 10**(m2)) + (v)
    

def karatsuba2(num1, num2):
    
    if num1 < 10 or num2 < 10:
        return num1*num2
    else:
       
        m = max(len(str(num1)), len(str(num2)))
        m2 = m//2

        num1_high = num1 // 10**(m2)
        num1_low  = num1 %  10**(m2)
        num2_high = num2 // 10**(m2)
        num2_low  = num2 %  10**(m2)

        v = karatsuba(num1_low, num2_low)
        w = karatsuba((num1_high-num1_low), (num2_high-num2_low))
        u = karatsuba(num1_high, num2_high)

        return (u * 10**(2*m2)) + ((u + v - w) * 10**(m2)) + (v)

a = 45132
b = 33213

print("Normal mult:", a*b)
kara_res = karatsuba(a,b)
print("Karatsuba:  ", kara_res)
kara_res2 = karatsuba2(a,b)
print("Karatsuba2: ", kara_res2)





a = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000"