#---------------------------------------------------------------------------------------#

operand:

  addi $sp, $sp, -8                         # Pushes our operand to the value stack
  sw $a0, 32($sp)
  sw $ra, 36($sp)                           # Save values to the stack

  move $a0, $s0                             # load the current value into func arguement
  move $a1, $s3                             # $a1 == $s3, top of the value stack
  move $a2, $s1                             # $a2 == $s1, address of the value stack

  jal stack_push                            # function call

  move $s3, $v0                             # update the top of the value stack

  lw $a0, 32($sp)
  lw $ra, 36($sp)                           # restore values from the stack
  addi $sp, $sp, 8

  j evaluation_loop                         # go back to the evaluation loop

#---------------------------------------------------------------------------------------#
