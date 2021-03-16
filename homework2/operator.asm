#---------------------------------------------------------------------------------------#

operator:

# args: $a0 = operator, $a1 = val_stack top, $a2 = op_stack addr

# return: $v0 = top of val_stack, $v1 = top of op_stack

# Preamble

addi $sp, $sp, -28
sw $s0, 0($sp)                      
sw $s1, 4($sp)                      
sw $s2, 8($sp)                      # Stores the precedence of the current operator

# Setup

sw $a0, 12($sp)                     # Store operator and top of our stacks onto the stack frame
sw $a1, 16($sp)                       
sw $a2, 20($sp)         
sw $ra, 24($sp)                      # Making function calls

# $a0 is our function arguement, so no need to load function args (they're already loaded)

jal op_precedence                   # make function call

move $s2, $v0                       # move operator precedence into $s2 -> save it for later

# Body

operator_loop:

    lw $a0, 20($sp)                 # Load the top of operator stack -> check if stack is empty

    jal is_stack_empty              # Calling stack_is_empty

    li $t0, 1                       # if op_stack is empty -> then we just push our operator onto the op stack
    beq $v0, $t0, operator_done

    lw $a0, 20($sp)                 # else -> peek the top of the stack, and get precedence of top operator
    la, $a1, op_stack
    addi $a1, $a1, 2000                  # Offsetting top of the operator stack

    jal stack_peek                  # Call to stack_peek
    
    li $t0, 40
    beq $v0, $t0, operator_done	    # if the item on the top of the stack is a left bracket -> then we're done

    move $a0, $v0                   # Move operator at top of the stack into $a0 -> call op_precedence

    jal op_precedence               # Call to op_precedence

    blt $v0, $s2, operator_done     # if top_of_stack < current_operator -> then push current operator

    # else we pop operator off the top of the stack, pop two values off of 
    # the value stack and push result back to value stack, then we go back through the loop

    lw $a0, 20($sp)                # Load top of operator stack into $a0
    la $a1, op_stack              # Load base address into $a1
    addi $a1, $a1, 2000

    jal stack_pop                  # Make function call

    sw $v1, 20($sp)                # Save new top of the operator stack
    move $s0, $v0                  # Save current operator in $s0

    lw $a0, 16($sp)                # Load top of value stack into $a0
    la $a1, val_stack              # Load address of value stack into $a1

    jal stack_pop                  # Pop first value off the value stack

    sw $v1, 16($sp)                # Store the new top of the value stack 
    move $s1, $v0                  # Move the first operand into $s1

    lw $a0, 16($sp)                # Load top of the value stack into $a0
    la $a1, val_stack              # Load address of the value stack into $a1

    jal stack_pop                  # Pop second value off the value stack

    sw $v1, 16($sp)                # Save the new top of the value stack

    move $a0, $v0                  # Apply binary operator to our two operands
    move $a1, $s0
    move $a2, $s1

    jal apply_bop                  # Apply the bop

    move $a0, $v0                  # Move the result into $a0 and push it back to the value stack
    lw $a1, 16($sp)                # Load the top of the value stack
    la $a2, val_stack              # Address of the value stack

    jal stack_push

    sw $v0, 16($sp)                # Update the new top of the value stack

    j operator_loop                # Go to the next loop iteration

operator_done:

    lw $a0, 12($sp)                      # Load operator into arg1
    lw $a1, 20($sp)                      # Load top of operator stack into arg2

    la $a2, op_stack                     # Load base address of operator stack into arg3
    addi $a2, $a2, 2000

    jal stack_push                       # Push operator onto the stack

    sw $v0, 20($sp)                      # Update the current top of the operator stack

    lw $v0, 16($sp)                      # Return top of value stack at $v0
    lw $v1, 20($sp)                      # Return top of operator stack at $v1

# Postamble

    lw $ra, 24($sp)                      # Restore return address

    lw $s0, 0($sp)                       # Restore the values of the $s registers
    lw $s1, 4($sp) 
    lw $s2, 8($sp)

    # I'm not going to bother to restore the values of the $a registers, I don't
    # think there is a reason to at the end here
    addi $sp, $sp, 28
    
    jr $ra                              # Return

#---------------------------------------------------------------------------------------#
