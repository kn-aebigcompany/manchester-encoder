`default_nettype none

module tt_um_manchester_encoder (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // Always 1 when the design is powered
    input  wire       clk,      // Clock
    input  wire       rst_n     // Active-low reset
);

    // Εσωτερικά σήματα
    logic        rst;
    logic        load;
    logic        start;
    logic [31:0] data_buf;
    logic        manchester_out;
    logic        busy;
    logic        done;

    // Μετατροπή του active-low rst_n σε active-high rst
    assign rst   = ~rst_n;
    assign load  = uio_in[0];
    assign start = uio_in[1];

    // Όλα τα uio pins ρυθμισμένα ως inputs
    assign uio_oe  = 8'b0000_0000;
    assign uio_out = 8'b0000_0000;

    // Φόρτωση 32-bit δεδομένων 1 byte τη φορά (MSB byte πρώτα)
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_buf <= 32'b0;
        end else if (load && !busy) begin
            data_buf <= {data_buf[23:0], ui_in};
        end
    end

    // Instantiation του encoder
    manchester_encoder u_encoder (
        .clk            (clk),
        .rst            (rst),
        .start          (start),
        .data_in        (data_buf),
        .manchester_out (manchester_out),
        .busy           (busy),
        .done           (done)
    );

    // Αντιστοίχιση εξόδων
    assign uo_out = {5'b0, done, busy, manchester_out};

    // Αποφυγή lint warnings για αχρησιμοποίητα pins
    wire _unused = &{ena, uio_in[7:2], 1'b0};

endmodule