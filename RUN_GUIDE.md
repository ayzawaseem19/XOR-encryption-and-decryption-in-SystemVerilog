Here's a shorter, cleaner README that still includes everything needed to run the project.

---

# XOR Cipher Project

This project implements an **8-bit XOR Cipher (Key = `11000011`)** in both **Python** and **SystemVerilog**. The Python version is used as a reference, while the SystemVerilog implementation is verified against it.

## Project Structure

```text
xor_project/
├── rtl/        # RTL design
├── tb/         # Testbenches
├── scripts/    # Python scripts and utilities
├── data/       # Input files
├── outputs/    # Generated simulation results
└── RUN_GUIDE.md
```

## Requirements

* Python 3
* NumPy
* Pillow
* Icarus Verilog (for SystemVerilog simulation)

Install Python packages:

```bash
pip install numpy pillow
```

---

# Python Execution

Generate a sample image (optional):

```bash
python3 scripts/gen_test_image.py
```

Run the Python implementation:

```bash
python3 scripts/xor_cipher_python.py
```

Outputs are saved in `outputs/`.

---

# SystemVerilog Execution

### Generate input files

```bash
python3 scripts/gen_vector.py
python3 scripts/img_to_hex.py
```

### Part 1 – Single Number

```bash
iverilog -g2012 -o outputs/sim_single.vvp rtl/xor_cipher_core.sv tb/tb_single_number.sv
vvp outputs/sim_single.vvp
```

### Part 2 – Vector

```bash
iverilog -g2012 -o outputs/sim_vector.vvp rtl/xor_cipher_core.sv rtl/xor_stream_top.sv tb/tb_vector.sv
vvp outputs/sim_vector.vvp
```

### Part 3 – Image

```bash
iverilog -g2012 -o outputs/sim_image.vvp rtl/xor_cipher_core.sv rtl/xor_stream_top.sv tb/tb_image.sv
vvp outputs/sim_image.vvp
```

Convert the generated HEX files back to images:

```bash
python3 scripts/hex_to_img.py
```

---

## Expected Outputs

The `outputs/` folder will contain:

* `image_cipher.png`
* `image_decrypted.png`
* `image_cipher_python.png`
* `image_decrypted_python.png`
* Simulation (`.vvp`) files
* Generated `.hex` files

The Python and SystemVerilog outputs should match, and the scripts will report **PASS** if verification is successful.
