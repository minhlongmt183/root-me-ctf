flag = [59, 2, 35, 27, 27, 12, 28, 8, 40, 27, 33, 4, 28, 11]
pbVar4 = [0x72,0x6f,0x6f,0x74,0x6d,0x65]

# ImLovingrootme

for i in range(len(flag)):
    try:
        print(chr(flag[i] ^ pbVar4[i % 6]), end="")
    except:
        print("i = ", i % 6)
