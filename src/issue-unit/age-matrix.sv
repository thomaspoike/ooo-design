module age_matrix (
    // inputs
    input logic clk,
    input logic reset,
    
    // Pointer defining which row in the issue queue a micro-op is going to be inserted
    input logic row_pointer,
    // Update age matrix signal
    input logic update_age_matrix,
    // Ready entries signal from the issue queue
    input logic [1:0] ready_entries,
    
    //input logic granted_entry,
    // outputs
    // One hot encoding to grant the oldest row in the issue queue
    output logic [1:0] grant_entry
);
    // Define 
    logic age_matrix [1:0][1:0];
    logic age_matrix_next [1:0][1:0];
    // Sequential logic
    always_ff @(posedge clk or negedge reset) begin
        if (!reset) begin
            age_matrix[0][0] <= 1'b0;
            age_matrix[0][1] <= 1'b0;
            age_matrix[1][0] <= 1'b0;
            age_matrix[1][1] <= 1'b0;
        end
        else if (update_age_matrix) begin
            age_matrix <= age_matrix_next;
        end
    end

    // Combinational logic
    // Row pointer 1 means row 1, 0 means row 2
    // First we follow the row pointer "m" to update age_matrix[m][m] = 1
    // Then we check if any other row "n" is already inserted, if yes we update their age_matrix[n][m] = 1
    always_comb begin
        // Row pointer is 1
        age_matrix_next = age_matrix;
        if (row_pointer == 1'b1) begin
            age_matrix_next[0][0] = 1'b1;
            if (age_matrix[1][1] == 1) begin
                age_matrix_next[1][0] = 1'b1;
                age_matrix_next[1][1] = 1'b1;
            end
            else begin
                age_matrix_next[1][0] = 1'b0;
                age_matrix_next[1][1] = 1'b0;
            end
            age_matrix_next[0][1] = 1'b0;            
        end
        else if (row_pointer == 1'b0) begin
            age_matrix_next[1][1] = 1'b1;
            if (age_matrix[0][0] == 1'b1) begin
                age_matrix_next[0][1] = 1'b1;
                age_matrix_next[0][0] = 1'b1;
            end
            else begin
                age_matrix_next[0][1] = 1'b0;
                age_matrix_next[0][0] = 1'b0;
            end
            age_matrix_next[1][0] = 1'b0;
        end
    end

    // Combinational logic for grant_entry one hot encoding
    assign grant_entry[0] = ((ready_entries[0] && age_matrix[0][0]) && (!ready_entries[1] || age_matrix[0][1]));
    assign grant_entry[1] = ((ready_entries[1] && age_matrix[1][1]) && (!ready_entries[0] || age_matrix[1][0]));

endmodule