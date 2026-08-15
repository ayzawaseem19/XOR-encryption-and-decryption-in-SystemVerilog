// =============================================================
// xor_stream_top.sv
// Synthesizable streaming XOR cipher.
// Wraps xor_cipher_core with a clocked valid/ready handshake so it
// can process a VECTOR of bytes or an IMAGE (as a byte stream) one
// sample per clock, which is how you would feed pixels from the
// HPS (ARM Cortex-A9) into the FPGA fabric on the DE1-SoC / DE10.
//
// Same module does encryption and decryption (XOR is involutory) -
// just feed plaintext bytes in for encryption, or ciphertext bytes
// in for decryption, using the same KEY both times.
//
// Fully synthesizable: single clocked always_ff block, no delays,
// no $display / file I/O (those only exist in the testbenches).
// =============================================================
module xor_stream_top #(
    parameter logic [7:0] KEY = 8'b11000011   // 8-bit key = 0xC3
)(
    input  logic        clk,
    input  logic        rst_n,      // active-low synchronous reset

    // Input stream (plaintext for encrypt, ciphertext for decrypt)
    input  logic [7:0]  in_data,
    input  logic         in_valid,
    output logic         in_ready,

    // Output stream (ciphertext for encrypt, plaintext for decrypt)
    output logic [7:0]  out_data,
    output logic         out_valid,
    input  logic         out_ready
);

    logic [7:0] core_out;

    // Combinational XOR core reused for both directions
    xor_cipher_core #(.KEY(KEY)) u_core (
        .data_in  (in_data),
        .data_out (core_out)
    );

    // Simple single-stage pipeline register with back-pressure.
    // in_ready is asserted whenever the output register is free
    // to accept a new value (i.e. not stalled by a downstream
    // consumer that isn't ready yet).
    assign in_ready = out_ready || !out_valid;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_data  <= 8'h00;
            out_valid <= 1'b0;
        end else begin
            if (in_valid && in_ready) begin
                out_data  <= core_out;
                out_valid <= 1'b1;
            end else if (out_ready) begin
                out_valid <= 1'b0;
            end
        end
    end

endmodule
