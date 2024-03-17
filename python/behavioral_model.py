# Python script for the behavioral model of a issue queue.

# Parameters
# 1. issue_queue_size: Size of the issue queue
issue_queue_size = 10
# 2. dispatch_width: Number of instructions that can be dispatched to issue queue
dispatch_width = 2
# 3. issue_width: Number of instructions that can be issued from issue queue
issue_width = 2


# Make a 10 entry issue queue
issue_queue = [0] * issue_queue_size

# function to dispatch instructions to issue queue
def dispatch_to_issue_queue(dispatch_width, issue_queue, amount_to_dispatch):
    for i in range(amount_to_dispatch):
        for j in range(dispatch_width):
            if issue_queue[i] == 0:
                issue_queue[i] = 1
                print("Dispatched instruction to issue queue at index: ", i)
                break

# function to issue instructions from issue queue
def issue_from_issue_queue(issue_width, issue_queue, amount_to_issue):
    for i in range(amount_to_issue):
        for j in range(issue_width):
            if issue_queue[i] == 1:
                issue_queue[i] = 0
                print("Issued instruction from issue queue at index: ", i)
                break

