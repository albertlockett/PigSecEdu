#!/usr/bin/python

import sys

def main():
	input = open(sys.argv[1],'r')
	text = input.readlines()
	for line in text:
		print line[1:-2]
	

if __name__ == '__main__':
	main()

