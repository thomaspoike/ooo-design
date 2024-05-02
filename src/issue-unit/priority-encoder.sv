module priority_encoder(
    input logic valid1, valid2,
    output logic priority1
);
    always_comb begin
        if (valid1) begin
            priority1 = 1'b1;
        end
        else if (valid2) begin
            priority1 = 1'b0;
        end
        else begin
            priority1 = 1'b0;
        end
    end
endmodule