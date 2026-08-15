// =============================================================
// xor_cipher_core.sv
// Purely combinational 8-bit XOR cipher core.
// Because XOR is its own inverse, THE SAME MODULE performs both
// encryption and decryption: cipher = plain ^ key, plain = cipher ^ key.
// Fully synthesizable (no delays, no $display, no system tasks).
// =============================================================
module xor_cipher_core #(
    parameter logic [7:0] KEY = 8'b11000011   // 8-bit key = 0xC3
)(
    input  logic [7:0] data_in,   // plaintext byte (encrypt) OR ciphertext byte (decrypt)
    output logic [7:0] data_out   // ciphertext byte (encrypt) OR plaintext byte (decrypt)
);

    assign data_out = data_in ^ KEY;

endmodule
