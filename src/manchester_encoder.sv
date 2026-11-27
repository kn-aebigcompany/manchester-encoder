module manchester_encoder (
    input  logic        clk,
    input  logic        rst,
    input  logic        start,
    input  logic [31:0] data_in,

    output logic        manchester_out,
    output logic        busy,
    output logic        done
);

    logic [31:0] data_reg;
    logic [5:0]  half_count;

    logic current_bit;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            data_reg       <= 32'b0;
            half_count     <= 6'd0;
            manchester_out <= 1'b0;
            busy           <= 1'b0;
            done           <= 1'b0;
        end
        else begin
            done <= 1'b0;

            // Start encoding
            if (start && !busy) begin
                data_reg   <= data_in;
                half_count <= 6'd1;
                busy       <= 1'b1;

                // First half of the MSB
                manchester_out <= ~data_in[31];
            end

            else if (busy) begin

                current_bit = data_reg[31 - (half_count / 2)];

                // IEEE 802.3 Manchester encoding
                manchester_out <= ~(current_bit ^ half_count[0]);

                if (half_count == 6'd63) begin
                    busy       <= 1'b0;
                    done       <= 1'b1;
                    half_count <= 6'd0;
                end
                else begin
                    half_count <= half_count + 1'b1;
                end
            end
        end
    end

endmodule