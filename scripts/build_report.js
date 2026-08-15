const fs = require("fs");
const {
  Document, Packer, Paragraph, TextRun, HeadingLevel, Table, TableRow, TableCell,
  WidthType, ShadingType, ImageRun, AlignmentType, BorderStyle, PageOrientation
} = require("docx");

const KEY_BIN = "1100 0011";
const KEY_HEX = "0xC3";
const KEY_DEC = "195";

function h1(text) {
  return new Paragraph({ text, heading: HeadingLevel.HEADING_1, spacing: { before: 300, after: 150 } });
}
function h2(text) {
  return new Paragraph({ text, heading: HeadingLevel.HEADING_2, spacing: { before: 240, after: 120 } });
}
function p(text, opts = {}) {
  return new Paragraph({ children: [new TextRun({ text, ...opts })], spacing: { after: 120 } });
}
function bullet(text) {
  return new Paragraph({ text, bullet: { level: 0 }, spacing: { after: 60 } });
}
function mono(text) {
  return new Paragraph({
    children: [new TextRun({ text, font: "Consolas", size: 18 })],
    spacing: { after: 60 },
  });
}
function cellText(text, opts = {}) {
  return new TableCell({
    width: { size: opts.width || 2000, type: WidthType.DXA },
    shading: opts.shade ? { type: ShadingType.CLEAR, fill: opts.shade } : undefined,
    children: [new Paragraph({ children: [new TextRun({ text, bold: opts.bold || false })] })],
  });
}

function simpleTable(headers, rows, widths) {
  const headerRow = new TableRow({
    children: headers.map((hdr, i) => cellText(hdr, { bold: true, shade: "D9D9D9", width: widths[i] })),
  });
  const dataRows = rows.map(
    (r) => new TableRow({ children: r.map((c, i) => cellText(String(c), { width: widths[i] })) })
  );
  return new Table({
    width: { size: widths.reduce((a, b) => a + b, 0), type: WidthType.DXA },
    columnWidths: widths,
    rows: [headerRow, ...dataRows],
  });
}

function img(path, w, h) {
  return new ImageRun({ type: "png", data: fs.readFileSync(path), transformation: { width: w, height: h } });
}

const doc = new Document({
  sections: [
    {
      properties: { page: { size: { width: 12240, height: 15840 } } }, // US Letter
      children: [
        new Paragraph({
          children: [new TextRun({ text: "8-bit XOR Cipher: Number, Vector & Image Encryption/Decryption", bold: true, size: 32 })],
          spacing: { after: 100 },
        }),
        new Paragraph({
          children: [new TextRun({ text: "FYDP Sub-Task Report — Software (Python) and Hardware (SystemVerilog) Implementations", italics: true, size: 22 })],
          spacing: { after: 300 },
        }),

        h1("1. Objective"),
        p(
          "Demonstrate an 8-bit XOR stream cipher, using the fixed key 11000011 (0xC3 = 195), " +
          "on three progressively larger data types: (a) a single 8-bit number, (b) a vector of 8-bit " +
          "numbers, and (c) a 256x256 8-bit grayscale image. Each task is implemented twice — once in " +
          "Python (software reference) and once in synthesizable SystemVerilog (hardware implementation, " +
          "verified in simulation) — by two team members working in parallel. This exercise validates the " +
          "team's RTL design and HPS-FPGA style data-streaming flow ahead of integrating the project's actual " +
          "chaotic encryption core."
        ),

        h1("2. Key and Method"),
        p("Key (8 bits): " + KEY_BIN + "  =  " + KEY_HEX + "  =  " + KEY_DEC + " (decimal)"),
        p(
          "XOR encryption is involutory: ciphertext = plaintext XOR key, and plaintext = ciphertext XOR key " +
          "using the exact same key. This means a single hardware/software block performs both encryption " +
          "and decryption — no separate decryption circuit is required."
        ),
        h2("2.1 Python method"),
        bullet("Part 1: single Python function xor_byte(value, key) applies value ^ key.")   ,
        bullet("Part 2: a 16-byte list is XOR'd element-wise with the same function."),
        bullet("Part 3: the 256x256 grayscale image is loaded with Pillow, converted to a NumPy uint8 array, and XOR'd against the key in a single vectorized numpy.bitwise_xor call."),
        bullet("File: scripts/xor_cipher_python.py"),

        h2("2.2 SystemVerilog method"),
        bullet("xor_cipher_core.sv — a purely combinational module: data_out = data_in ^ KEY. Used directly for Part 1 (single number)."),
        bullet("xor_stream_top.sv — wraps the core in a single clocked pipeline stage with a valid/ready handshake (clk, rst_n, in_data/in_valid/in_ready, out_data/out_valid/out_ready), so it can stream a vector or an image one byte per clock cycle — the same interface style used to move pixel data between the HPS and FPGA fabric on the DE1-SoC/DE10."),
        bullet("Both encryption and decryption use the SAME module and the SAME key parameter; only the stream fed into it differs (plaintext bytes vs. ciphertext bytes)."),
        bullet("Both RTL files are 100% synthesizable: no delays (#), no $display/file I/O, no initial blocks — only combinational assign statements and one always_ff block with a synchronous-clear reset."),
        bullet("Separate, clearly-marked testbenches (tb_single_number.sv, tb_vector.sv, tb_image.sv) provide stimulus, drive the handshake, and dump results to hex files for cross-checking against the Python output. Testbenches are simulation-only and are not part of the synthesizable design."),

        h1("3. Part 1 Results — Single Number"),
        simpleTable(
          ["", "Value (bin)", "Value (hex)", "Value (dec)"],
          [
            ["Key", "11000011", "0xC3", "195"],
            ["Plaintext", "11001000", "0xC8", "200"],
            ["Ciphertext", "00001011", "0x0B", "11"],
            ["Decrypted", "11001000", "0xC8", "200"],
          ],
          [2200, 2400, 2200, 2200]
        ),
        p(""),
        p("Result: decrypted value = original plaintext, in both Python and SystemVerilog simulation. PASS.", { bold: true }),

        h1("4. Part 2 Results — Vector (16 bytes)"),
        mono("Plaintext  : [10, 200, 55, 128, 0, 255, 77, 33, 9, 250, 61, 190, 5, 222, 100, 47]"),
        mono("Ciphertext : [201, 11, 244, 67, 195, 60, 142, 226, 202, 57, 254, 125, 198, 29, 167, 236]"),
        mono("Decrypted  : [10, 200, 55, 128, 0, 255, 77, 33, 9, 250, 61, 190, 5, 222, 100, 47]"),
        p("Result: decrypted vector is identical to the original in both Python and SystemVerilog simulation, byte-for-byte. PASS.", { bold: true }),

        h1("5. Part 3 Results — 256x256 Grayscale Image"),
        p("A 256x256 8-bit grayscale test image (concentric-ring gradient pattern) was streamed pixel-by-pixel (65,536 pixels) through the XOR core in simulation, encrypted, then decrypted."),
        new Table({
          width: { size: 9600, type: WidthType.DXA },
          columnWidths: [3200, 3200, 3200],
          rows: [
            new TableRow({ children: [
              cellText("Original (plaintext)", { bold: true, width: 3200 }),
              cellText("Encrypted (ciphertext)", { bold: true, width: 3200 }),
              cellText("Decrypted", { bold: true, width: 3200 }),
            ]}),
            new TableRow({ children: [
              new TableCell({ width: { size: 3200, type: WidthType.DXA }, children: [new Paragraph({ children: [img("data/plain_image.png", 200, 200)], alignment: AlignmentType.CENTER })] }),
              new TableCell({ width: { size: 3200, type: WidthType.DXA }, children: [new Paragraph({ children: [img("outputs/image_cipher.png", 200, 200)], alignment: AlignmentType.CENTER })] }),
              new TableCell({ width: { size: 3200, type: WidthType.DXA }, children: [new Paragraph({ children: [img("outputs/image_decrypted.png", 200, 200)], alignment: AlignmentType.CENTER })] }),
            ]}),
          ],
        }),
        p(""),
        p("Result: RESULT: PASS - decrypted image is bit-exact with the original (verified pixel-by-pixel, 0 mismatches out of 65,536). The Python and SystemVerilog ciphertext images were also compared and are pixel-for-pixel identical, confirming both implementations agree.", { bold: true }),
        p(
          "Note: a fixed single-byte XOR key is a very weak cipher for images — because the key repeats every byte, " +
          "large flat regions of the image XOR to a single repeated value, so the outline/structure of the original " +
          "image often remains visible in the ciphertext (see table above). This is expected and is precisely the " +
          "motivation for the team's actual FYDP deliverable: a chaotic-map-based keystream, which does not repeat " +
          "and removes this structural leakage. This XOR exercise's purpose was to validate the streaming " +
          "hardware/software data path, not to serve as the final encryption scheme."
        ),

        h1("6. Verification Methodology"),
        bullet("Python: pytest-style manual PASS/FAIL check comparing decrypted output to original input (numbers, vector) and NumPy array equality (image)."),
        bullet("SystemVerilog: each testbench streams data through the DUT via a clocked valid/ready handshake, captures the DUT's output into an array, and performs an element-wise / pixel-wise comparison against the original input at the end of simulation, printing PASS/FAIL and a mismatch count."),
        bullet("Cross-check: SV ciphertext/decrypted hex outputs were converted back to PNG and compared byte-for-byte against the Python outputs — confirmed identical."),
        bullet("Tooling used: Icarus Verilog (iverilog/vvp) for simulation; Python 3 with NumPy and Pillow for the software side and for image conversion utilities."),
        bullet("Synthesizability: rtl/xor_cipher_core.sv and rtl/xor_stream_top.sv contain zero simulation-only constructs (no #delays, $display, or file I/O) and passed iverilog's synthesis-subset lint (-Wall) with zero warnings."),

        h1("7. File / Deliverable Summary"),
        simpleTable(
          ["File", "Purpose"],
          [
            ["rtl/xor_cipher_core.sv", "Synthesizable combinational XOR core (Part 1)"],
            ["rtl/xor_stream_top.sv", "Synthesizable clocked streaming wrapper (Parts 2 & 3)"],
            ["tb/tb_single_number.sv", "Testbench: Part 1"],
            ["tb/tb_vector.sv", "Testbench: Part 2"],
            ["tb/tb_image.sv", "Testbench: Part 3"],
            ["scripts/xor_cipher_python.py", "Python implementation of all 3 parts"],
            ["scripts/gen_vector.py / gen_test_image.py", "Generate sample test data"],
            ["scripts/img_to_hex.py / hex_to_img.py", "Convert image <-> hex for SV $readmemh"],
            ["RUN_GUIDE.md", "Step-by-step instructions to run everything"],
          ],
          [4200, 5400]
        ),

        h1("8. Conclusion"),
        p(
          "Both the Python and SystemVerilog implementations of the 8-bit XOR cipher (key = 11000011) were " +
          "successfully built, simulated, and cross-verified for a single number, a 16-byte vector, and a " +
          "256x256 grayscale image. All three parts recovered the original data exactly after decryption " +
          "(0 mismatches), and the SystemVerilog RTL is fully synthesizable and ready to be targeted to the " +
          "DE1-SoC / DE10 (Cyclone V) boards, or extended directly to carry the chaotic-map keystream instead " +
          "of the fixed key used here."
        ),
      ],
    },
  ],
});

Packer.toBuffer(doc).then((buf) => {
  fs.writeFileSync("outputs/XOR_Cipher_Report.docx", buf);
  console.log("Wrote outputs/XOR_Cipher_Report.docx");
});
