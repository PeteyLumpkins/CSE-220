############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

############################## Do not .include any files! #############################

.text
eval:
  jr $ra

#---------------------------------------------------------------------------------------#

is_digit:
  addi $sp, $sp -4                # first we make space on the stack for 1 item
  sw $s0, 0($sp)                  # push value in reg $s0 to stack

  li $s0, 48                      # if char < 48 ('0') then -> return 0
  blt $a0, $s0, is_not_digit

  li $s0, 57                      # if char > 57 ('9') then -> return 0
  bgt $a0, $s0, is_not_digit

  li $v0, 1                       # else 48 <= char <= 57 -> return 1
  j done_1

is_not_digit:
  li $v0, 0                       # return 0

done_1:
  lw $s0, 0($sp)                  # restore value of $s0
  addi $sp, $sp, 4                # adjust the stack pointer

  jr $ra                          # return $v0

#---------------------------------------------------------------------------------------#

stack_push:
  jr $ra

stack_peek:
  jr $ra

stack_pop:
  jr $ra

is_stack_empty:
  jr $ra

#---------------------------------------------------------------------------------------#

valid_ops:

  addi $sp, $sp, -4
  sw $s0, 0($sp)

  li $s0, 42                      # if char == '*' (42) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 43                      # else if char == '+' (43) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 45                      # else if char == '-' (45) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 47                      # else if char == '/' (47) then -> return 1
  beq $a0, $s0, is_valid_ops
                                  # else char is invalid operator -> return 0 
is_not_valid_ops:
  li $v0, 0
  j done_2

is_valid_ops:
  li $v0, 1

done_2:

  lw $s0, 0($sp)
  addi $sp, $sp, 42

  jr $ra

#---------------------------------------------------------------------------------------#

op_precedence:
  jr $ra

apply_bop:
  jr $ra
