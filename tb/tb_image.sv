// =============================================================
// tb_image.sv
// PART 3: Encrypt then decrypt a 256x256 GRAYSCALE IMAGE.
// The image is pre-converted (by scripts/img_to_hex.py) into a
// flat file of 65536 hex bytes, one pixel per line, in
// row-major order. This testbench streams every pixel through
// xor_stream_top one byte per clock (same core as Part 1/2).
//
// Reads : data/image_plain.hex   (65536 lines, plaintext pixels)
// Writes: outputs/image_cipher.hex     (encrypted pixels)
//         outputs/image_decrypted.hex  (decrypted pixels, == plain)
//
// Stimulus driven on negedge, DUT clocked on posedge (see tb_vector.sv
// for why - avoids a same-edge race with the DUT's registers).
//
// Simulation-only file (uses $readmemh/$fopen/$display) - NOT synthesized.
// =============================================================
`timescale 1ns/1ps

module tb_image;

    localparam logic [7:0] KEY      = 8'b11000011; // 0xC3
    localparam int         IMG_W    = 256;
    localparam int         IMG_H    = 256;
    localparam int         N_PIX    = IMG_W * IMG_H; // 65536

    logic clk = 0;
    logic rst_n;

    logic [7:0] enc_in_data,  enc_out_data;
    logic       enc_in_valid, enc_in_ready, enc_out_valid, enc_out_ready;

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

    logic [7:0] plain_img [0:N_PIX-1];
    logic [7:0] cipher_img[0:N_PIX-1];
    logic [7:0] decr_img  [0:N_PIX-1];

    integer f_cipher, f_decr;
    int i;
    int errors;
    int enc_cnt, dec_cnt;

    always @(negedge clk) begin
        if (rst_n && enc_out_valid && enc_out_ready) begin
            cipher_img[enc_cnt] <= enc_out_data;
            enc_cnt <= enc_cnt + 1;
        end
    end

    always @(negedge clk) begin
        if (rst_n && dec_out_valid && dec_out_ready) begin
            decr_img[dec_cnt] <= dec_out_data;
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

        $display("================ PART 3: 256x256 IMAGE ================");
        $display("Loading data/image_plain.hex (%0d pixels)...", N_PIX);
        $readmemh("data/image_plain.hex", plain_img);

        // ---- ENCRYPT: stream every pixel through u_enc ----
        i = 0;
        while (i < N_PIX) begin
            @(negedge clk);
            if (enc_in_ready) begin
                enc_in_data  = plain_img[i];
                enc_in_valid = 1;
                i = i + 1;
            end
        end
        @(negedge clk);
        enc_in_valid = 0;
        while (enc_cnt < N_PIX) @(negedge clk);
        $display("Encryption stream complete (%0d pixels sent).", N_PIX);

        // ---- DECRYPT: stream ciphertext pixels through u_dec ----
        i = 0;
        while (i < N_PIX) begin
            @(negedge clk);
            if (dec_in_ready) begin
                dec_in_data  = cipher_img[i];
                dec_in_valid = 1;
                i = i + 1;
            end
        end
        @(negedge clk);
        dec_in_valid = 0;
        while (dec_cnt < N_PIX) @(negedge clk);
        $display("Decryption stream complete (%0d pixels sent).", N_PIX);

        repeat (3) @(negedge clk);

        errors = 0;
        for (i = 0; i < N_PIX; i++)
            if (decr_img[i] !== plain_img[i]) errors++;

        if (errors == 0)
            $display("RESULT: PASS - decrypted image is bit-exact with the original.");
        else
            $display("RESULT: FAIL - %0d pixel mismatches!", errors);

        f_cipher = $fopen("outputs/image_cipher.hex", "w");
        f_decr   = $fopen("outputs/image_decrypted.hex", "w");
        for (i = 0; i < N_PIX; i++) begin
            $fdisplay(f_cipher, "%02h", cipher_img[i]);
            $fdisplay(f_decr,   "%02h", decr_img[i]);
        end
        $fclose(f_cipher);
        $fclose(f_decr);

        $display("Wrote outputs/image_cipher.hex and outputs/image_decrypted.hex");
        $display("=========================================================");
        $finish;
    end

endmodule
