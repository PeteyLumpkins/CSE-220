#---------------------------------------------------------------------------------------#

eval:

# Preamble

  addi $sp, $sp, -24
  
  sw $s0, 0($sp)                            # Current token we're working with
  sw $s1, 4($sp)                            # Top of the value stack
  sw $s2, 8($sp)                            # Top of the operator stack
  sw $s3, 12($sp)                           # Starting index of the next token

# Setup

  sw $a0, 16($sp)                           # Store our expression on the stack frame
  sw $ra, 20($sp)                           # Store return address on the stack frame

  # for the operator stack, I'm incrementing the base address by 2000 to make room for the other
  # 500 elements that could possibly get pushed to the value stack

# Initialize the tops of the stacks, and the starting index to 0

  and $s1, $s1, $0                          # Top of value stack
  and $s2, $s2, $0                          # Top of operator stack
  and $s3, $s3, $0                          # Starting index of expression

# Main loop -> pretty much does all of the work

evaluation_loop:

  lw $a0, 16($sp)                           # Load expression address into arg1
  move $a1, $s3                             # Load index of next token into arg2

  jal next_token                            # Call next token to get the next token

  # next_token will return 0 in $v1 if the next token is the null terminator

  beqz $v1, finish_evaluating               # if next_token == null terminator -> jump to finish evaluating

  li $t0, 1 
  sub $t1, $v1, $s3                         # take the difference between the starting indices of the exp
  
  move $s0, $v0                             # Move the next token into $s0
  move $s3, $v1                             # Update the starting index of the next token in the expression
  
  bne $t1, $t0, operand                     # if difference != 1 -> then it's a digit greater than 9

  li $t0, 40
  beq $s0, $t0, left_bracket               # if $s0 == 40 -> then it's a left bracket

  li $t0, 41
  beq $s0, $t0, call_right_bracket         # if $s0 == 41 -> call right bracket function

  # Call is operator function

  move $a0, $s0                            # Load function arguement             

  jal valid_ops                            # Calling valid_ops

  li $t0, 1
  beq $v0, $t0, call_operator              # if $s0 is a valid operator -> call the operator function

  j operand                                # final case -> $s0 is a digit 0 <= $s0 <= 9

call_operator:

  # return address and expression should already be saved on the stack

  move $a0, $s0                            # Load operator into $a0
  move $a1, $s1                            # Load the top of the value stack -> $a1
  move $a2, $s2                            # Load the top of the op stack -> $a2

  jal operator                             # Calling operator function

  move $s1, $v0                            # Update top of the value stack
  move $s2, $v1                            # Update top of the operator stack

  j evaluation_loop                        # Go back to the loop

call_right_bracket:

  # return address and expression are all saved -> just need to load function arguements

  move $a0, $s1                           # Move top of the val_stack into $a0
  move $a1, $s2                           # Move top of the op_stack into $a1
  la $a2, val_stack                       # Load address of the value stack

  la $a3, op_stack                        # Load address of the operator stack
  addi $a3, $a3, 2000                     # Offset by 2000 to account for 500 elements in the val_stack

  jal right_bracket                       # Calling right_bracket

  move $s1, $v0                           # update the top of the value stack
  move $s2, $v1                           # update the top of the operator stack

  j evaluation_loop                       # Go back to the loop

left_bracket:                             # Pushes left bracket to operator stack
                                            
  move $a0, $s0                           # Left bracket
  move $a1, $s2                           # Top of operator stack
  la $a2, op_stack                        # Base address of the stack
  addi $a2, $a2, 2000                     # Off set by 2000

  jal stack_push                          # Calling stack push

  move $s2, $v0                           # Update value of the top of the operator stack

  j evaluation_loop                       # Go to the next character

operand:  

  # $ra register has already been saved previously (calling stack_push in eval function still)

  move $a0, $s0                            # $a0 == current operand
  move $a1, $s1                            # $a1 == $s1, top of the value stack
  la $a2, val_stack                        # $a2 == address of the value stack

  jal stack_push                            # function call

  move $s1, $v0                             # update the top of the value stack

  j evaluation_loop                         # go back to the evaluation loop

finish_evaluating:

  # at this point, we have reached the end of the expression -> all we have to do is keep 
  # applying the remaining operators on the operator stack to the values on the values stack
  # until operator stack is empty -> our final result (return value) should be the first value
  # on the value stack

  move $a0, $s2                           # checking if operator stack is empty

  jal is_stack_empty                      # calling is empty

  li $t0, 1
  beq $v0, $t0, evaluation_done           # if operator stack is empty -> then we're done

  # else -> we need to pop an operator and two values -> registers $s0 and $s3 are both free

  move $a0, $s2                           # top of the operator stack
  la $a1, op_stack                        # address of operator stack
  addi $a1, $a1, 2000

  jal stack_pop 

  move $s2, $v1                           # adjust top of operator stack
  move $s0, $v0                           # move operator into $s0

  move $a0, $s1                           # top of the value stack
  la $a1, val_stack                       # address of the value stack

  jal stack_pop

  move $s1, $v1                           # update top of the value stack
  move $s3, $v0                           # move first value into $s3

  move $a0, $s1                           # top of the value stack
  la $a1, val_stack                       # address of the value stack

  jal stack_pop

  move $s1, $v1                           # update the top of the value stack

  move $a0, $v0                           # move the second value -> first arg of apply_bop
  move $a1, $s0                           # operator
  move $a2, $s3                           # move first value popped off stack into $a2

  jal apply_bop

  move $a0, $v0                           # push result back to the value stack
  move $a1, $s1
  la $a2, val_stack

  jal stack_push                          # calling stack push

  move $s1, $v0                           # update the top of the value stack

  j finish_evaluating                     # go back through the loop

evaluation_done:

  move $a0, $s1                           # load the top of the value stack
  la $a1, val_stack                       # load the base address of the value stack

  jal stack_pop                           # pop value off of the top of the value stack

  # currently, the value we want to return is already in $v0, so no need to move it 

  lw $ra 20($sp)                          # restore the return address

  # not restoring $a0 -> we don't care about it... I don't think

  lw $s0, 0($sp)                          # restore $s registers we used
  lw $s1, 4($sp)
  lw $s2, 8($sp)
  lw $s3, 12($sp)

  jr $ra                                  # return... ??? 

#---------------------------------------------------------------------------------------#
