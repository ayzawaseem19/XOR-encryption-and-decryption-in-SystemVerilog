// =============================================================
// tb_vector.sv
// PART 2: Encrypt then decrypt a VECTOR (array) of 8-bit numbers,
// streamed one byte per clock through xor_stream_top.
// Reads data/input_vector.hex, writes:
//   outputs/vector_cipher.hex    (encrypted vector)
//   outputs/vector_decrypted.hex (decrypted vector, should == input)
//
// Stimulus is driven on the CLOCK'S NEGEDGE and the DUT is clocked
// on POSEDGE. This is standard testbench practice: it guarantees
// inputs are stable well before every posedge, so there is no
// same-edge race between the testbench and the DUT's registers.
//
// Simulation-only file (uses $readmemh/$display) - NOT synthesized.
// =============================================================
`timescale 1ns/1ps

module tb_vector;

    localparam logic [7:0] KEY      = 8'b11000011; // 0xC3
    localparam int         VEC_LEN  = 16;           // change to match your vector length

    logic clk = 0;
    logic rst_n;

    // ---- signals for the ENCRYPT instance ----
    logic [7:0] enc_in_data,  enc_out_data;
    logic       enc_in_valid, enc_in_ready, enc_out_valid, enc_out_ready;

    // ---- signals for the DECRYPT instance ----
    logic [7:0] dec_in_data,  dec_out_data;
    logic       dec_in_valid, dec_in_ready, dec_out_valid, dec_out_ready;

    xor_stream_top #(.KEY(KEY)) u_enc (
        .clk(clk), .rst_n(rst_n),
        .in_data(enc_in_data),   .in_valid(enc_in_valid),   .in_ready(enc_in_ready),
        .out_data(enc_out_data), .out_valid(enc_out_valid), .out_ready(enc_out_ready)
    );

    xor_stream_top #(.KEY(KEY)) u_dec (
        .clk(clk), .rst_n(rst_n),
        .in_data(dec_in_data),   .in_valid(dec_in_valid),   .in_ready(dec_in_ready),
        .out_data(dec_out_data), .out_valid(dec_out_valid), .out_ready(dec_out_ready)
    );

    always #5 clk = ~clk; // 100 MHz sim clock

    logic [7:0] plain_vec [0:VEC_LEN-1];
    logic [7:0] cipher_vec[0:VEC_LEN-1];
    logic [7:0] decr_vec  [0:VEC_LEN-1];

    integer f_cipher, f_decr;
    integer i;
    integer errors;
    integer enc_cnt, dec_cnt;

    // Capture encrypt output bytes into cipher_vec as they arrive.
    // Sampled on negedge: enc_out_valid/enc_out_data were registered
    // on the posedge half a cycle earlier, so they are guaranteed
    // stable here - no race with the DUT.
    always @(negedge clk) begin
        if (rst_n && enc_out_valid && enc_out_ready) begin
            cipher_vec[enc_cnt] <= enc_out_data;
            enc_cnt <= enc_cnt + 1;
        end
    end

    // Capture decrypt output bytes into decr_vec as they arrive
    always @(negedge clk) begin
        if (rst_n && dec_out_valid && dec_out_ready) begin
            decr_vec[dec_cnt] <= dec_out_data;
            dec_cnt <= dec_cnt + 1;
        end
    end

    initial begin
        rst_n = 0;
        enc_in_valid = 0; enc_out_ready = 1;
        dec_in_valid = 0; dec_out_ready = 1;
        enc_cnt = 0; dec_cnt = 0;
        repeat (3) @(negedge clk);
        rst_n = 1;

        // Read plaintext vector from file (one 2-digit hex byte per line)
        $readmemh("data/input_vector.hex", plain_vec);

        $display("================ PART 2: VECTOR ================");
        $write("Plaintext vector : ");
        for (i = 0; i < VEC_LEN; i++) $write("%0d ", plain_vec[i]);
        $display("");

        // ---- ENCRYPT: stream plaintext vector through u_enc ----
        i = 0;
        while (i < VEC_LEN) begin
            @(negedge clk);
            if (enc_in_ready) begin
                enc_in_data  = plain_vec[i];
                enc_in_valid = 1;
                i = i + 1;
            end
        end
        @(negedge clk);
        enc_in_valid = 0;

        // Let the pipelined encrypt output fully drain into cipher_vec
        // before using it as the decrypt input.
        while (enc_cnt < VEC_LEN) @(negedge clk);

        // ---- DECRYPT: stream ciphertext vector through u_dec ----
        i = 0;
        while (i < VEC_LEN) begin
            @(negedge clk);
            if (dec_in_ready) begin
                dec_in_data  = cipher_vec[i];
                dec_in_valid = 1;
                i = i + 1;
            end
        end
        @(negedge clk);
        dec_in_valid = 0;

        while (dec_cnt < VEC_LEN) @(negedge clk);
        repeat (3) @(negedge clk);

        $write("Ciphertext vector: ");
        for (i = 0; i < VEC_LEN; i++) $write("%0d ", cipher_vec[i]);
        $display("");
        $write("Decrypted vector : ");
        for (i = 0; i < VEC_LEN; i++) $write("%0d ", decr_vec[i]);
        $display("");

        errors = 0;
        for (i = 0; i < VEC_LEN; i++)
            if (decr_vec[i] !== plain_vec[i]) errors++;

        if (errors == 0)
            $display("RESULT: PASS - decrypted vector matches original plaintext vector.");
        else
            $display("RESULT: FAIL - %0d mismatches!", errors);

        // Write results out to hex files for the report / Python comparison
        f_cipher = $fopen("outputs/vector_cipher.hex", "w");
        f_decr   = $fopen("outputs/vector_decrypted.hex", "w");
        for (i = 0; i < VEC_LEN; i++) begin
            $fdisplay(f_cipher, "%02h", cipher_vec[i]);
            $fdisplay(f_decr,   "%02h", decr_vec[i]);
        end
        $fclose(f_cipher);
        $fclose(f_decr);

        $display("==================================================");
        $finish;
    end

endmodule
