module age_matrix #(
    NUM_ENTRIES = 4
) (
    input wire clk,
    input wire reset,
    input wire row_pointer,
    input wire [NUM_ENTRIES-1:0] valid_entries,
    input wire update_age_matrix,
    input wire [NUM_ENTRIES-1:0] ready_entries
);
    reg age_matrix [NUM_ENTRIES-1:0] [NUM_ENTRIES-1:0];
    reg age_matrix_next [NUM_ENTRIES-1:0] [NUM_ENTRIES-1:0];
    reg grant_vector [NUM_ENTRIES-1:0];
    // Sequential logic
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < NUM_ENTRIES; i++) begin
                for (int j = 0; j < NUM_ENTRIES; j++) begin
                    age_matrix[i][j] <= 0;
                end
            end
        end else begin

        end
    end

    // Combinational logic
    always_comb begin : combinational_logic
        // Initialize all elements to 0 as a default.
        automatic int row_index = row_pointer;
        // Initialize only the elements in the row_pointer row to 0.
        for (int j = 0; j < NUM_ENTRIES; j++) begin
            age_matrix_next[row_index][j] = 0;
        end
        case (row_pointer)
            2'b00: begin 
                age_matrix_next[0][0] = 1; // Set the first element as per specific need
                // Iterate over the valid_entries, setting age_matrix_next[i][0] based on validity
                for (int i = 1; i < NUM_ENTRIES; i++) begin
                    age_matrix_next[i][0] = valid_entries[i] ? 1 : 0;
                end
            end
            2'b01: begin           // Specific logic for row_pointer 01
            // age_matrix_next[1][1] = 1;
                for (int i = 0; i < NUM_ENTRIES; i++) begin
                    age_matrix_next[i][1] = valid_entries[i] ? 1 : 0;
                    
                end
            end
            2'b10: begin           // Specific logic for row_pointer 10
                for (int i = 0; i < NUM_ENTRIES; i++) begin
                    age_matrix_next[i][2] = valid_entries[i] ? 1 : 0;
                end
            end
            2'b11: begin          // Specific logic for row_pointer 11
                for (int i = 0; i < NUM_ENTRIES; i++) begin
                    age_matrix_next[i][3] = valid_entries[i] ? 1 : 0;
                end
            end
        endcase
    end

    always_comb begin : grant_vector_logic
        grant_vector[0] = (age_matrix[0][0] & ready_entries[0]) & (age_matrix[0][1] | ready_entries[1]) & (age_matrix[0][2] | ready_entries[2]) & (age_matrix[0][3] | ready_entries[3]);

        grant_vector[1] = (age_matrix[1][1] & ready_entries[1]) & (age_matrix[1][0] | ready_entries[0]) & (age_matrix[1][2] | ready_entries[2]) & (age_matrix[1][3] | ready_entries[3]);

        grant_vector[2] = (age_matrix[2][2] & ready_entries[2]) & (age_matrix[2][0] | ready_entries[0]) & (age_matrix[2][1] | ready_entries[1]) & (age_matrix[2][3] | ready_entries[3]);
        
        grant_vector[3] = (age_matrix[3][3] & ready_entries[3]) & (age_matrix[3][0] | ready_entries[0]) & (age_matrix[3][1] | ready_entries[1]) & (age_matrix[3][2] | ready_entries[2]);
    end
endmodule