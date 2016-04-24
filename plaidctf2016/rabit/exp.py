#!/usr/bin/env python

from pwn import *
import subprocess as sp
from Crypto.Util.number import bytes_to_long, long_to_bytes
import sys

sys.setrecursionlimit(0x1000)

def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    assert g == 1
    return x % m

def proof():
    r.recvuntil('work:\n')
    prefix = r.recvline().split(' ')[6][:-1]
    p = sp.Popen('./sha1prefix {}'.format(prefix), shell=True, stdout=sp.PIPE)
    r.sendline(p.stdout.read().strip())

padchar = '\x00'
def pad(s):
    assert(len(s) < N.bit_length() / 8)
    padded = bytes_to_long(s.ljust(N.bit_length()/8, padchar))
    while decrypt(padded, p, q) == None:
        padded += 1
    return padded

#r = remote('localhost', 7763)
r = remote('rabit.pwning.xxx', 7763)
proof()
r.recvuntil('N = ')
N = int(r.recvline())
log.info('N: ' + str(N))
r.recvuntil('Flag: ')
flag = int(r.recvline())
log.info('flag: ' + str(flag))


inv = modinv(4, N)
tmp_m = flag

ub = N 
lb = 0

# m0
for i in range(250):
    r.recvuntil('ciphertext: ')
    r.sendline(str(flag * pow(2,2*(i+1),N) % N))
    ret = r.recvline()
    print ret
    if '0' in ret:
        ub = (ub + lb)/2
    else:
        lb = (ub + lb)/2
print ub
print lb
'''
for i in range(10):
    tmp_m = (tmp_m >> 2 << 2) * inv % N
    r.recvuntil('ciphertext: ')
    r.sendline(str(tmp_m))
    print i,
    print r.recvline()

for i in range(100):
    inv = modinv(pow(2,i), N)
    tmp_m = (flag >> i+1 << i+1) * pow(inv, 2, N) % N
    r.recvuntil('ciphertext: ')
    r.sendline(str(tmp_m))
    print i,
    print r.recvline()
'''

r.interactive()
