"""
gen_vector.py
Creates data/input_vector.hex: 16 bytes, one 2-digit hex value per line,
readable by SystemVerilog's $readmemh. Edit VECTOR below for your own data.
"""
import os

VECTOR = [10, 200, 55, 128, 0, 255, 77, 33, 9, 250, 61, 190, 5, 222, 100, 47]

os.makedirs("data", exist_ok=True)
with open("data/input_vector.hex", "w") as f:
    for v in VECTOR:
        f.write(f"{v:02x}\n")

print(f"Wrote data/input_vector.hex with {len(VECTOR)} bytes: {VECTOR}")
