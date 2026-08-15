"""
gen_test_image.py
Generates a sample 256x256 grayscale PNG test image so you have
something to run through the pipeline immediately. Replace with your
own real 256x256 grayscale image if you have one -- just make sure to
resize/convert it to 'L' (8-bit grayscale) mode first, e.g.:

    from PIL import Image
    Image.open("your_photo.jpg").convert("L").resize((256, 256)).save("data/plain_image.png")
"""
import os
import numpy as np
from PIL import Image

os.makedirs("data", exist_ok=True)

size = 256
x = np.linspace(0, 255, size)
y = np.linspace(0, 255, size)
xx, yy = np.meshgrid(x, y)

# A gradient + concentric-circle pattern so the encrypted image
# visibly looks like noise compared to the structured original.
cx, cy = size / 2, size / 2
radius = np.sqrt((xx - cx) ** 2 + (yy - cy) ** 2)
pattern = (xx * 0.5 + 64 * np.sin(radius / 8)) % 256
img = pattern.astype(np.uint8)

Image.fromarray(img, mode="L").save("data/plain_image.png")
print("Wrote data/plain_image.png (256x256, 8-bit grayscale)")
