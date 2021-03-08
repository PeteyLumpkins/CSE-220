#---------------------------------------------------------------------------------------#

case_is_left_bracket:                       # Pushes left bracket to operator stack

  addi $sp, $sp, -8                         # Preamble
  sw $a0, 0($sp)
  sw $ra, 4($sp)
                                            
  move $a0, $s0                             # Item we want to push to stack
  move $a1, $s4                             # Top of operator stack
  move $a2, $s2                             # Base address of the stack

  jal stack_push

  move $s4, $v0                             # Update value of the top of the operator stack

  lw $a0, 0($sp)                              
  lw $ra, 4($sp)
  addi $sp, $sp, 8                          # Postamble

  j evaluation_loop

#---------------------------------------------------------------------------------------#
