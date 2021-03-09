#---------------------------------------------------------------------------------------#

right_bracket:

# args: $a0 = val_stack top, $a1 = op_stack top, $a2 = val_stack addr, $a3 = op_stack addr

# return: $v0 = top of val_stack, $v1 = top of op_stack

# Preamble

addi $sp, $sp, -28                         # I'm going to need 3 $s registers for this
sw $s0, 0($sp)                             # so we'll save $s0, $s1, $s2
sw $s1, 4($sp)
sw $s2, 8($sp)

sw $a0, 12($sp)                            # Top of value stack 
sw $a1, 16($sp)                            # Top of operator stack
sw $a2, 20($sp)                            # Address of value stack
sw $ra, 24($sp)                            # Save return address

right_bracket_loop:

# First we check if the stack is empty

  lw $a0, 16($sp)                          # Load function args

  jal is_stack_empty                       # Function call

  li $t0, 1
  beq $v0, $t0, print_parse_error_message      # if op_stack is empty -> parse error  

# Calling the pop function on the operator stack to get initial value on the top of the stack

  lw $a0, 16($sp)                          # Top of operator stack -> arg1
  move $a1, $a3                            # Address of operator stack -> arg2

  jal stack_pop                            # Function call

  move $s0, $v0                            # Move operator into register $s0 -> save for later
  sw $v1, 16($sp)                          # Store/replace our running top of the op_stack

  li $t0, 40                               # if top_of_stack == 40 ('(') -> go back to the loop
  beq $s0, $t0, right_bracket_post         # else -> pop 1 op, pop 2 values, push 1 value

# If our top of the stack is not a left bracket, we have to pop two values off of the value stack,
# apply the operator at 0 to them, and push the result back to the stack

  lw $a0, 12($sp)                           # Load top of the value stack -> arg1
  lw $a1, 20($sp)                           # Load address of value stack -> arg2

  jal stack_pop                             # Function call

  move $s1, $v0                             # Move first value into register $s1 -> save for later
  sw $v1, 12($sp)                           # Adjust/Replace top of the value stack

  lw $a0, 12($sp)                           # Make another call to stack_pop to
  lw $a1, 20($sp)                           # get the second valuee

  jal stack_pop                             # Function call

  move $s2, $v0                             # Move second value into register $s2 -> save for later
  sw $v1, 12($sp)                           # Adjust top of the val_stack

  lw $a0, 12($sp)                           # Check if our stack is empty

  jal is_stack_empty                        # Function call
  
  beqz $v0, print_parse_error_message       # if underflow occurs in value stack -> parse error

  move $a0, $s1                             # first integer == $s1
  move $a1, $s0                             # operator == $s0
  move $a2, $s2                             # second integer == $s2

  jal apply_bop                             # apply our operator to the values

  move $a0, $v0                             # push $v0 back to value stack 
  lw $a1, 12($sp)                               # Load top of the value stack -> arg2
  lw $a2, 20($sp)                             # Load address of the value stack -> arg3

  jal stack_push                            # function call

  sw $v0, 12($sp)                           # adjust the top of the value stack

  j right_bracket_loop                      # go back to the start of the loop, must find left bracket
  
  right_bracket_post:

    lw $s0, 0($sp) 
    lw $s1, 4($sp) 
    lw $s2, 8($sp)  

    lw $a0, 12($sp) 
    lw $a1, 16($sp)  
    lw $a2, 20($sp)
    lw $ra, 24($sp)
    addi $sp, $sp, 28 
    
    jr $ra                      	    # return

#---------------------------------------------------------------------------------------#
