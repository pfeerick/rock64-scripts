#!/usr/bin/python3

# Modification of a script by longsleep for the pine64
# by Mark Hays Harris for the rock64
# https://forum.pine64.org/showthread.php?tid=4695&pid=28913#pid28913

import sys
import string

def convert(value):
    value = value.upper()
    bank_num = int(value[4:5], 10)
    reg_num = int(value[7:], 10)
    gpionum = (bank_num * 32) + reg_num
    return gpionum

if __name__ == "__main__":
    args = sys.argv[1:]
    if not args:
        print("Usage: %s <bank_reg>  ie; GPIO3_A5" % sys.argv[0])
        sys.exit(1)

    print("%d" % convert(args[0]))
    
