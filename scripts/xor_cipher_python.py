"""
xor_cipher_python.py
The PYTHON-side implementation of the same 8-bit XOR cipher used in the
SystemVerilog design, for the team's software half of the report.
Key = 8'b11000011 = 0xC3 = 195.

Run:  python3 scripts/xor_cipher_python.py
"""
import os
import numpy as np
from PIL import Image

KEY = 0b11000011  # 0xC3 = 195


# ---------- Part 1: single number ----------
def xor_byte(value: int, key: int = KEY) -> int:
    return (value ^ key) & 0xFF


def part1_single_number():
    plaintext = 200
    ciphertext = xor_byte(plaintext)
    decrypted = xor_byte(ciphertext)

    print("================ PART 1: SINGLE NUMBER (Python) ================")
    print(f"Key         = {KEY:08b} (0x{KEY:02X} = {KEY})")
    print(f"Plaintext   = {plaintext:08b} (0x{plaintext:02X} = {plaintext})")
    print(f"Ciphertext  = {ciphertext:08b} (0x{ciphertext:02X} = {ciphertext})")
    print(f"Decrypted   = {decrypted:08b} (0x{decrypted:02X} = {decrypted})")
    print("RESULT:", "PASS" if decrypted == plaintext else "FAIL")
    print()


# ---------- Part 2: vector ----------
def part2_vector():
    plain_vec = [10, 200, 55, 128, 0, 255, 77, 33, 9, 250, 61, 190, 5, 222, 100, 47]
    cipher_vec = [xor_byte(v) for v in plain_vec]
    decr_vec = [xor_byte(v) for v in cipher_vec]

    print("================ PART 2: VECTOR (Python) ================")
    print("Plaintext vector :", plain_vec)
    print("Ciphertext vector:", cipher_vec)
    print("Decrypted vector :", decr_vec)
    print("RESULT:", "PASS" if decr_vec == plain_vec else "FAIL")
    print()

    os.makedirs("outputs", exist_ok=True)
    with open("outputs/vector_cipher_python.hex", "w") as f:
        for v in cipher_vec:
            f.write(f"{v:02x}\n")


# ---------- Part 3: 256x256 grayscale image ----------
def part3_image():
    in_path = "data/plain_image.png"
    if not os.path.exists(in_path):
        print(f"Skipping Part 3 - {in_path} not found. "
              f"Run scripts/gen_test_image.py first (or drop your own 256x256 image there).")
        return

    img = Image.open(in_path).convert("L")
    if img.size != (256, 256):
        img = img.resize((256, 256))
    arr = np.array(img, dtype=np.uint8)

    cipher_arr = np.bitwise_xor(arr, KEY).astype(np.uint8)
    decr_arr = np.bitwise_xor(cipher_arr, KEY).astype(np.uint8)

    os.makedirs("outputs", exist_ok=True)
    Image.fromarray(cipher_arr, mode="L").save("outputs/image_cipher_python.png")
    Image.fromarray(decr_arr, mode="L").save("outputs/image_decrypted_python.png")

    print("================ PART 3: 256x256 IMAGE (Python) ================")
    print(f"Loaded {in_path}, shape={arr.shape}")
    print("Wrote outputs/image_cipher_python.png and outputs/image_decrypted_python.png")
    print("RESULT:", "PASS" if np.array_equal(arr, decr_arr) else "FAIL")
    print()


if __name__ == "__main__":
    part1_single_number()
    part2_vector()
    part3_image()
