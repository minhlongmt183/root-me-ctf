
flag = [None]*19
for i in range(8, 17):
	flag[i] = 0x69
flag[0] = 0x63
flag[1] = 0x61
flag[2] = 0x6e
flag[3] = 0x74
flag[4] = 0x72
flag[5] = flag[4] + 3
flag[6] = 0x6e
flag[7] = 0x6d

flag[17] = 0x70
flag[18] = 0x73

print(	)
print("password: ", end="")
for i in flag:
	print(chr(i), end="")
print()