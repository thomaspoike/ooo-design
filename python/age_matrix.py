# Logic for age matrix n x n

class age_matrix:

    def __init__(self, n):
        self.n = n
        self.matrix = [[0 for i in range(n)] for j in range(n)]
        # Valid rows are the diagonal of the matrix
        self.valid_rows = [1 for i in range(n)]
        self.inserted_instruction = ["" for i in range(n)]
        self.age_array = [0 for i in range(n)]

    # Get the valid rows of the matrix
    def get_valid_rows(self):
        self.valid_rows = [1 if (self.matrix[i][i]==0) else 0 for i in range(self.n)]
        return self.valid_rows
    
    def calculate_age_rows(self):
        for i in range(self.n):
            self.age_array[i] = sum(self.matrix[i])

    def calculate_age_row(self, row):
        return sum(self.matrix[row])

    def get(self, i, j):
        return self.matrix[i][j]

    def set(self, row, number=1):
        self.matrix[row][row] = number
    
    def get_first_valid_row(self):
        for index, valid_flag in enumerate(self.get_valid_rows()):
            if valid_flag == 1:
                return index
        return -1
    
    def insert_instruction(self, instruction):
        valid_row = self.get_first_valid_row()
        if valid_row != -1:
            self.inserted_instruction[valid_row] = instruction
        
        self.set(valid_row)

        valid_rows = self.get_valid_rows()

        for index, valid_flag in enumerate(valid_rows):
            if valid_flag == 1:
                self.matrix[valid_row][index] = 0
            else:
                self.matrix[index][valid_row] = 1

    def dispatch_old(self):
        self.calculate_age_rows()
        # Find index of the oldest row
        oldest_row = self.age_array.index(max(self.age_array))
        for i in range(self.n):
            self.matrix[oldest_row][i] = 0
        # self.pretty_print()
        self.inserted_instruction[oldest_row] = ""



    def __len__(self):
        return self.n
    
    def pretty_print(self):
        for i in range(self.n):
            print(self.matrix[i], self.calculate_age_row(i), self.inserted_instruction[i])
 
    

    

# Create a 4x4 age matrix
age_matrix_4x4 = age_matrix(4)
age_matrix_4x4.pretty_print()
print("___________")
#print(age_matrix_4x4.get_valid_rows())

age_matrix_4x4.insert_instruction("Instruction 1")
age_matrix_4x4.insert_instruction("Instruction 2")
age_matrix_4x4.insert_instruction("Instruction 3")

age_matrix_4x4.pretty_print()
print("___________")
age_matrix_4x4.dispatch_old()
age_matrix_4x4.insert_instruction("Instruction 4")
age_matrix_4x4.pretty_print()

print("___________")
age_matrix_4x4.dispatch_old()
age_matrix_4x4.pretty_print()
