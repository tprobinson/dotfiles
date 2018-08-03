#!/usr/bin/python
 
import sys
import time
 
def entropy_avail():
    with open('/proc/sys/kernel/random/entropy_avail') as infile:
        return long(infile.read())
 
if __name__ == '__main__':
    delay = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    while True:
        print entropy_avail()
        time.sleep(delay)
