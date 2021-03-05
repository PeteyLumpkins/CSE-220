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

  addi $sp, $sp, -4           # make space on the stack for $s0
  sw $s0, 0($sp)

  li $s0, 42                     # if multiplication -> return 2 (higher prec)
  beq $a0, $s0, high_prec 
  li $s0, 47                     # if division -> return 2 (higher prec)
  beq $a0, $s0, high_prec
  li $s0, 43                     # if addition -> return 1 (lower prec)
  beq $a0, $s0, low_prec         
  li $s0, 45                     # if substraction -> return 1 (lower prec)
  beq $a0, $s0, low_prec
  j load_error_1

high_prec:                       # if higher prec -> return 2
  li $v0, 2
  j done_3

low_prec:                         # if lower prec -> return 1
  li $v0, 1
  j done_3

load_error_1:                     # if invalid operator -> returnn -1
    li $v0, -1

done_3:
  lw $s0, 0($sp)                 # restore $s0 from the stack
  addi $sp, $sp, 4               # adjust our stack pointer again

  jr $ra
 
#---------------------------------------------------------------------------------------#

apply_bop:    # apply_boop (int v1 = $a0, char op = $a1, int v2 = $a2)

  addi $sp, $sp, -8             # add space on the stack
  sw $s0, 0($sp)                # store $s0 on the stack
  sw $s1, 4($sp)                # store $s1 on thee stack

  li $s0, 43                    # if (op = '+') -> perform addition
  beq $a1, $s0, do_addition
  li $s0, 45                    # if (op = '-') -> perform subtraction
  beq $a1, $s0, do_subtraction
  li $s0, 42                    # if (op = '*') -> perform multiplication
  beq $a1, $s0, do_multiplication   
  jr $ra

do_addition:
  add $v0, $a0, $a2

do_subtraction:
  sub $v0, $a0, $a2

do_multiplication:
  mul $v0, $a0, $a2             # this should put the lower 32-bits into $v0
  
do_division:
  div $a0, $a2
  mflo $s0

  lui $s1, 0x8000               # check to see if our quotient is negative or not
  and $s0, $s0, $s1             # by checking the sign bit of mflo
  bnez $s0, floor_negative      # if sign-bit != 0 -> floor_negative

  mfhi $s0                      # check to see if our remainder is negative or not
  and $s0, $s0, $s1             # by checking the sign bit of mfhi
  bnez $s0, floor_negative      # if sign-bit != 0 -> floor_negative

floor_positive:                 # else -> floor positive (just take quotient that's
  mflo $v0                      #         in mflo and return)
  j apply_bop_done

floor_negative:                 # if remainder != 0, then we subtract one from the quotient
  mfhi $s0
  mflo $v0
  bnez $s0, subtract_one
  j apply_bop_done

subtract_one:
  addi $v0, $v0, -1

apply_bop_done:

  lw $s0, 0($sp)                # restore $s0 from the stack
  lw $s1, 4($sp)                # restore $s1 from the stack
  addi $sp, 8                   # adjust stack pointer to top of stack

  jr $ra                        # return at $v0

#---------------------------------------------------------------------------------------#
