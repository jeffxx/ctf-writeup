#/usr/bin/env python

from Crypto.Random import random, atfork
from Crypto.Util.number import bytes_to_long, long_to_bytes
from hashlib import sha1

import SocketServer,threading,os,time
import signal

from util import *
#from key import *

'''
key = genKey(1024)
p = key[0][0]
q = key[0][1]
N = key[1]
'''
p = 13363684560223502811744895362148666174424225355118451101093601411949270863941354181405872559934403546943985626222129131047852320553342157211823174934556407
q = 7983692058472776409119970586835246379015495696255086726852090299257724069433551421454535535240839341589813961241345951759688505856292621957494332694069039
N = p * q

padchar = '\x00'


PORT = 7763
FLAG = "REDACTED"
msg = """Welcome to the LSB oracle! N = {}\n""".format(N)


def pad(s):
    assert(len(s) < N.bit_length() / 8)
    padded = bytes_to_long(s.ljust(N.bit_length()/8, padchar))
    while decrypt(padded, p, q) == None:
        padded += 1
    return padded

padded = pad(FLAG)
print padded
enc_flag = encrypt(padded, N)

assert long_to_bytes(padded)[:len(FLAG)] == FLAG
assert decrypt(enc_flag, p, q) == padded
assert decrypt(2, p, q) != None

def proof_of_work(req):
    import string
    req.sendall("Before we begin, a quick proof of work:\n")
    prefix = "".join([random.choice(string.digits + string.letters) for i in range(10)])
    req.sendall("Give me a string starting with {}, of length {}, such that its sha1 sum ends in ffffff\n".format(prefix, len(prefix)+5))
    response = req.recv(len(prefix) + 5)
    if sha1(response).digest()[-3:] != "\xff"*3 or not response.startswith(prefix):
        req.sendall("Doesn't work, sorry.\n")
        exit()

class incoming(SocketServer.BaseRequestHandler):
    def handle(self):
        atfork()
        req = self.request
        signal.alarm(60)

        def recvline():
            buf = ""
            while not buf.endswith("\n"):
                buf += req.recv(1)
            return buf

        #proof_of_work(req)

        signal.alarm(120)

        req.sendall(msg)

        req.sendall("Encrypted Flag: {}\n".format(enc_flag))
        while True:
            req.sendall("Give a ciphertext: ")
            x = long(recvline())
            m = decrypt(x, p, q)
            print m
            if m == None:
                #req.sendall(str(x) + ': None\n')
                m = 0
            req.sendall("lsb is {}\n".format(m % 2))

        req.close()

class ReusableTCPServer(SocketServer.ForkingMixIn, SocketServer.TCPServer):
  pass

SocketServer.TCPServer.allow_reuse_address = True
server = ReusableTCPServer(("0.0.0.0", PORT), incoming)

print "Listening on port %d" % PORT
server.serve_forever()
