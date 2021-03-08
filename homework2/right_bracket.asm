#---------------------------------------------------------------------------------------#

right_bracket:         

# First check if the stack is empty. If it is empty, then we throw a parse error

right_bracket_pre:

  addi $sp, $sp, -8                        # Preamble
  sw $a0, 0($sp)                           # Save the expressions start address
  sw $ra, 4($sp)                           # Save return address

right_bracket_loop:

  move $a0, $s4                            # Load function args

  jal is_stack_empty                       # Function call

  beqz $v0, print_parse_error_message      # if op_stack is empty -> parse erro   

# Calling the pop function on the operator stack to get initial value on the top of the stack

  move $a0, $s4                             # Load function arguements
  move $a1, $s2

  jal stack_pop                             # Function call

  move $s6, $v0                             # Move operator into register $s6
  move $s4, $v1                             # Adjust our running top of the op_stack

  li $t1, 40                                # if top_of_stack == 40 ('(') -> go back to the loop
  beq $s6, $t1, right_bracket_post             # else -> pop 1 op, pop 2 values, push 1 value

# If our top of the stack is not a left bracket, we have to pop two values off of the value stack,
# apply the operator at 0 to them, and push the result back to the stack

  addi $sp, $sp, -8
  sw $a0, 0($sp)
  sw $ra, 4($sp)

  move $a0, $s3                             # Top of the value stack == $s3
  move $a1, $s1                             # Base addrees of value stack == $s1

  jal stack_pop                             # Function call

  move $s5, $v0                             # Move first value into register $t1
  move $s3, $v1                             # Adjust top of the stack

  move $a0, $s3                             # Make another call to stack_pop to
  move $a1, $s1                             # get the second valuee

  jal stack_pop                             # Function call

  move $s7, $v0                             # Move second value into register $t2
  move $s3, $v1                             # Adjust top of the stack

  move $a0, $s3                             # Check if our stack is empty

  jal is_stack_empty                        # Function call

  beqz $v0, print_parse_error_message       # if underflow occurs in value stack -> parse error

  move $a0, $s5                             # first integer == $s5
  move $a1, $s6                             # operator == $s6
  move $a2, $s7                             # second integer == $s7

  jal apply_bop                             # apply our operator to the values

  move $a0, $v0                             # push $v0 back to value stack 
  move $a1, $s3
  move $a2, $s1

  jal stack_push                            # function call

  move $s3, $v0                             # adjust the top of the stack

  j right_bracket_pre                       # go back to the start of the loop, must find left bracket
  
  right_bracket_post:

    lw $a0, 0($sp)                            
    lw $ra, 4($sp)
    addi $sp, $sp, 8

    j evaluation_loop                       # jump back to the main loop
    
#---------------------------------------------------------------------------------------#
