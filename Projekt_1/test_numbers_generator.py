import random

bits = 64
hex_vals = int(bits/4)
num_of_tests = 500

tv_file = open("test_vectors.txt", "a")
for ii in range(num_of_tests):
    A = ''.join(random.choice('0123456789abcdef') for n in range(hex_vals))
    B = ''.join(random.choice('0123456789abcdef') for n in range(hex_vals))
    tv_file.write(A+"\n")
    tv_file.write(B+"\n")
tv_file.close()