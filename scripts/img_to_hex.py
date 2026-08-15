"""
img_to_hex.py
Converts a 256x256 grayscale image (data/plain_image.png) into a flat
hex file (data/image_plain.hex) -- one pixel per line, row-major order,
2 hex digits per byte -- that SystemVerilog's $readmemh can load.
"""
import os
import numpy as np
from PIL import Image

IN_PATH  = "data/plain_image.png"
OUT_PATH = "data/image_plain.hex"

img = Image.open(IN_PATH).convert("L")
if img.size != (256, 256):
    img = img.resize((256, 256))
    print(f"Note: resized input image to 256x256")

arr = np.array(img, dtype=np.uint8)  # shape (256, 256), row-major
flat = arr.flatten()                 # row-major, matches SV loop order

os.makedirs("data", exist_ok=True)
with open(OUT_PATH, "w") as f:
    for px in flat:
        f.write(f"{px:02x}\n")

print(f"Wrote {OUT_PATH}: {flat.size} pixels from {IN_PATH}")
