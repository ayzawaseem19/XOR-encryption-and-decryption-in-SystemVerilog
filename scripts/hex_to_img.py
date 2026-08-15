"""
hex_to_img.py
Converts the SystemVerilog testbench outputs
(outputs/image_cipher.hex and outputs/image_decrypted.hex) back into
viewable 256x256 PNG images, and verifies the decrypted image is
bit-exact with the original plaintext image.
"""
import numpy as np
from PIL import Image

W = H = 256

def hex_to_array(path):
    with open(path) as f:
        vals = [int(line.strip(), 16) for line in f if line.strip()]
    arr = np.array(vals, dtype=np.uint8)
    return arr.reshape((H, W))

cipher_arr = hex_to_array("outputs/image_cipher.hex")
decr_arr   = hex_to_array("outputs/image_decrypted.hex")
plain_arr  = np.array(Image.open("data/plain_image.png").convert("L"))

Image.fromarray(cipher_arr, mode="L").save("outputs/image_cipher.png")
Image.fromarray(decr_arr,   mode="L").save("outputs/image_decrypted.png")

print("Wrote outputs/image_cipher.png and outputs/image_decrypted.png")

if np.array_equal(plain_arr, decr_arr):
    print("VERIFICATION: PASS - decrypted image is bit-exact with the original.")
else:
    diff = np.count_nonzero(plain_arr != decr_arr)
    print(f"VERIFICATION: FAIL - {diff} pixels differ!")
