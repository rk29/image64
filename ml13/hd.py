#!/usr/bin/env python

import sys

def hexdump(f):
	addr = 0
	s = f.read(16)
	while s:
		print "%04x" % addr,
		addr = addr + 16
		for ch in s:
			print "%02x" % ord(ch),
		s1 = ""
		for ch in s:
			if ord(ch) in range(32,127):
				s1 = s1 + ch
			else:
				s1 = s1 + "."
		print s1
		s = f.read(16)

if __name__ == "__main__":
	f = open(sys.argv[1], "r")
	hexdump(f)
	f.close()
