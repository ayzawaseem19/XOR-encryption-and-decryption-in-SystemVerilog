// =============================================================
// tb_single_number.sv
// PART 1: Encrypt then decrypt ONE 8-bit number with key 11000011.
// Simulation-only file (uses $display) - NOT synthesized.
// =============================================================
`timescale 1ns/1ps

module tb_single_number;

    localparam logic [7:0] KEY = 8'b11000011; // 0xC3

    logic [7:0] plaintext, ciphertext, decrypted;

    xor_cipher_core #(.KEY(KEY)) u_enc (.data_in(plaintext),  .data_out(ciphertext));
    xor_cipher_core #(.KEY(KEY)) u_dec (.data_in(ciphertext), .data_out(decrypted));

    initial begin
        plaintext = 8'd200;  // example number to encrypt (change as needed)
        #10;

        $display("================ PART 1: SINGLE NUMBER ================");
        $display("Key         = %b (0x%0h = %0d)", KEY, KEY, KEY);
        $display("Plaintext   = %b (0x%0h = %0d)", plaintext,  plaintext,  plaintext);
        $display("Ciphertext  = %b (0x%0h = %0d)", ciphertext, ciphertext, ciphertext);
        $display("Decrypted   = %b (0x%0h = %0d)", decrypted,  decrypted,  decrypted);

        if (decrypted === plaintext)
            $display("RESULT: PASS - decrypted value matches original plaintext.");
        else
            $display("RESULT: FAIL - mismatch!");

        $display("=========================================================");
        $finish;
    end

endmodule
