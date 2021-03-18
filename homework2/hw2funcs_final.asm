#---------------------------------------------------------------------------------------#

is_digit:

# Preamble

  addi $sp, $sp -4                # first we make space on the stack for 1 item
  sw $s0, 0($sp)                  # push value in reg $s0 to stack

# Body

  li $s0, 48                      # if char < 48 ('0') then -> return 0
  blt $a0, $s0, is_not_digit

  li $s0, 57                      # if char > 57 ('9') then -> return 0
  bgt $a0, $s0, is_not_digit

  li $v0, 1                       # else 48 <= char <= 57 -> return 1
  j is_digit_done

is_not_digit:
  li $v0, 0                       # return 0

is_digit_done:

# Postamble 

  lw $s0, 0($sp)                  # restore value of $s0
  addi $sp, $sp, 4                # adjust the stack pointer

  jr $ra                          # return $v0

#---------------------------------------------------------------------------------------#

stack_push:                       # a0 = element, $a1 = top, $a2 = base address

# Preamble

  addi $sp, $sp, -4               # allocate space on stack frame
  sw $s0, 0($sp)                  # save $s0 on the stack

# Body 

  addi $s0, $a2, 2000             # the capacity of the stack is 500 elements that 
  beq $a1, $s0, stack_push_overflow    # each take up 4 bytes -> 500 * 4 = 2000

  add $a2, $a2, $a1               # increment base address to the top of the stack
  sw $a0, 0($a2)                  # then store our value at the top of the stack

  addi $v0, $a1, 4                # we want to return the top of the stack + 4, to give   
  j stack_push_done               # us the new top of the stack


stack_push_overflow:                   
  j print_apply_op_error          # if stack overflow occurs -> print apply op error 

stack_push_done:

# Postamble

  lw $s0, 0($sp)                  # restore $s0 from the stack
  addi $sp, $sp, 4                # adjust top of the stack

  jr $ra                          # return

#---------------------------------------------------------------------------------------#

stack_peek:                       # $a0 = top of stack $a1 = base address of stack

# Preamble 

  addi $sp, $sp, -8               # make space on the stack for $s0
  sw $s0, 0($sp)                  # save register $s0 to the stack
  lw $s1, 4($sp)                  # save register $s1 to the stack 

# Body

  addi $s0, $a0, -4               # calculate where are element is on our stack
  li $s1, -4

  ble $s0, $s1, stack_peek_underflow    # if our position is less than -4, than we have underflow

  add $v0, $a1, $s0               # get position of the top of the stack
  lw $v0, 0($v0)                  # move value at the top of the stack into $v0
  j stack_peek_done               # return $v0

  stack_peek_underflow:                
    j print_apply_op_error        # if underflow occurs, print apply_op_error

  stack_peek_done:

# Postamble

    lw $s0, 0($sp)                # restore $s0 from the stack
    lw $s1, 4($sp)
    addi $sp, $sp, 8              # adjust stack pointer

    jr $ra                        # return $v0

#---------------------------------------------------------------------------------------#

stack_pop:                        # $a0 = top of the stack, $a1 = base address of stack

# Preamble

  addi $sp, $sp, -4               # make space on the stack for $s0
  sw $s0, 0($sp)                  # save $s0 onto the stack         

# Body

  addi $v1, $a0, -4               # calculate new top of the stack
  li $s0, -4                      # if stack pointer < -4 -> underflow

  ble $v1, $s0, stack_pop_underflow     # if top ($v1) < base_address -> stack is empty 

  add $a1, $a1, $v1               # else we add $v1 to base address, and  
  lw $v0, 0($a1)                  # return the element at top of stack
  j stack_pop_done

stack_pop_underflow:              # if stack underflow occurs then print apply op error
  j print_apply_op_error

# Postamble

stack_pop_done: 

  lw $s0, 0($sp)                  # restore $s0 from the stack
  addi $sp, $sp, 4                # adjust the stack pointer
  jr $ra                          # return $v0 == popped element, $v1 == new top of stack

#---------------------------------------------------------------------------------------#

is_stack_empty:                   # $a0 == top of the stack

# Preamble

  addi $sp, $sp, -4               # make space on the stack for $s0
  sw $s0, 0($sp)                  # save reg $s0 on the stack      f

# Body

  addi $a0, $a0, -4               # if stack_pointer =< -4 -> then it's empty
  li $s0, -4        
  ble $a0, $s0, is_empty
  li $v0, 0
  j is_stack_empty_done

is_empty:
  li $v0, 1

is_stack_empty_done:

# Postamble

  lw $s0, 0($sp)                  # restore $s0
  addi $sp, $sp, 4                # adjust stack pointer

  jr $ra                          # return: if stack is empty -> $v0 = 1 else $v0 = 0

#---------------------------------------------------------------------------------------#

valid_ops:

# Preamble

  addi $sp, $sp, -4
  sw $s0, 0($sp)

# Body

  li $s0, 42                      # if char == '*' (42) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 43                      # else if char == '+' (43) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 45                      # else if char == '-' (45) then -> return 1
  beq $a0, $s0, is_valid_ops
  li $s0, 47                      # else if char == '/' (47) then -> return 1
  beq $a0, $s0, is_valid_ops      # else char is invalid operator -> return 0 

is_not_valid_ops:
  li $v0, 0
  j valid_ops_done

is_valid_ops:
  li $v0, 1

valid_ops_done:

# Postamble

  lw $s0, 0($sp)                  # restore $s0 
  addi $sp, $sp, 4                # adjust top of the stack pointer

  jr $ra                          # return

#---------------------------------------------------------------------------------------#

op_precedence:

# Preamble

  addi $sp, $sp, -4              # make space on the stack for $s0
  sw $s0, 0($sp)

# Body

  li $s0, 42                     # if multiplication -> return 2 (higher prec)
  beq $a0, $s0, high_prec 
  li $s0, 47                     # if division -> return 2 (higher prec)
  beq $a0, $s0, high_prec
  li $s0, 43                     # if addition -> return 1 (lower prec)
  beq $a0, $s0, low_prec         
  li $s0, 45                     # if subtraction -> return 1 (lower prec)
  beq $a0, $s0, low_prec
  j print_wrong_arg_message      # arguement is not a valid operator -> print error

high_prec:
  li $v0, 2
  j op_precedence_done

low_prec:
  li $v0, 1
  j op_precedence_done

op_precedence_done:

# Postamble

  lw $s0, 0($sp)                 # restore $s0 from the stack
  addi $sp, $sp, 4               # adjust our stack pointer again

  jr $ra

#---------------------------------------------------------------------------------------#

apply_bop:                      # apply_boop (int v1 = $a0, char op = $a1, int v2 = $a2)

# Preamble  

  addi $sp, $sp, -8             # add space on the stack
  sw $s0, 0($sp)                # store $s0 on the stack
  sw $s1, 4($sp)                # store $s1 on thee stack

# Body 

  li $s0, 43                    # if (op = '+') -> perform addition
  beq $a1, $s0, do_addition
  
  li $s0, 45                    # if (op = '-') -> perform subtraction
  beq $a1, $s0, do_subtraction
  
  li $s0, 42                    # if (op = '*') -> perform multiplication
  beq $a1, $s0, do_multiplication  
   
  li $s0, 47
  beq $a1, $s0, do_division	    # if (op = '/') -> perform division

do_addition:                    # return $a0 + $a2
  add $v0, $a0, $a2
  j apply_bop_done

do_subtraction:                 # return $a0 - $a2
  sub $v0, $a0, $a2
  j apply_bop_done

do_multiplication:              # return $a0 * $a2
  mul $v0, $a0, $a2             # this should put the lower 32-bits into $v0
  j apply_bop_done
  
do_division:                    # return floor($a0 / $a2)

  beqz $a2, print_apply_op_error      # DIVIDE BY ZERO!

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
  mfhi $s0                      # to floor it
  mflo $v0
  bnez $s0, subtract_one
  j apply_bop_done

subtract_one:
  addi $v0, $v0, -1

apply_bop_done:

# Postamble 

  lw $s0, 0($sp)                # restore $s0 from the stack
  lw $s1, 4($sp)                # restore $s1 from the stack
  addi $sp, $sp, 8              # adjust stack pointer to top of stack

  jr $ra                        # return at $v0

#---------------------------------------------------------------------------------------#

# The following "methods" are here for printing error messages. When an error message
# is encountered the program terminates by jumping to the terminate_program label.

#---------------------------------------------------------------------------------------#

print_wrong_arg_message:
  la $a0, WrongArgMsg
  li $v0, 4
  syscall 

  j terminate_program

#---------------------------------------------------------------------------------------#

print_bad_token_message:
  la $a0, BadToken
  li $v0, 4
  syscall

  j terminate_program

#---------------------------------------------------------------------------------------#

print_parse_error_message:
  la $a0, ParseError
  li $v0, 4
  syscall

  j terminate_program

#---------------------------------------------------------------------------------------#

print_apply_op_error:
  la $a0, ApplyOpError
  li $v0, 4
  syscall

  j terminate_program

#---------------------------------------------------------------------------------------#

terminate_program:              # y'all already know
  li $v0, 10
  syscall
  
#---------------------------------------------------------------------------------------#
#
# The following methods are actual helper methods to handle cases in the 
# evaluate function. 
#
#---------------------------------------------------------------------------------------#

check_valid_character:	# checks if the given character is a valid character or not

	# takes one arguements, $a0 -> the character to validate
	
	addi $sp, $sp, -8			# save the value of $s0 and $s1 to the stack
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
	li $s0, 40
	beq $a0, $s0, valid_character_leftbracket		# if char is '(' -> then return valid
	
	li $s0, 41
	beq $a0, $s0, valid_character_rightbracket	        # if char is ')' -> then return valid
	
	move $s0, $a0				# move $a0 into $s0 -> prevserving value
	
	# arg1 = $a0 -> should still be our character
	# also -> return address has already been saved to the stack
	
	jal valid_ops				# call valid ops on $a0 (our character)
	
	li $t0, 1
	beq $v0, $t0, valid_character_operator		# if char is valid_op -> then return valid
	
	move $a0, $s0

	jal is_digit				# call is_digit
	
	li $t0, 1
	beq $v0, $t0, valid_character_digit	# if char is_digit -> then return valid
	
	j invalid_character			# else -> character must be invalid
	
valid_character_operator:
	li $v0, 4
	j valid_character_done
	
valid_character_rightbracket:
	li $v0, 3
	j valid_character_done
	
valid_character_leftbracket:			
	li $v0, 2
	j valid_character_done
valid_character_digit:
	li $v0, 1
	j valid_character_done
	
invalid_character:
	li $v0, 0
	
valid_character_done:

	lw $s0, 0($sp)				# restore values from the stack
	lw $ra, 4($sp)				# restore return address
	addi $sp, $sp, 8
	
	jr $ra					# if valid and digit -> 1, if valid and left_bracket -> 2 
						# if valid and right_bracket -> 3, if valid and operator -> 4, else invalid -> 0
						
#---------------------------------------------------------------------------------------#
#
# operator -> when we need to push an operator onto the op_stack, the operator function
#	      takes control of the program and performs the appropriate operations
#
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
#
# next_token -> collects and builds the next token from our expression string whether it
#		is an operator or an operand. Also checks the format of the expression is
#		valid
#
#---------------------------------------------------------------------------------------#

next_token:         # $a0 == base address of the equation   # $a1 == starting index

# Preamble

    addi $sp, $sp, -16
    sw $s0, 0($sp)
    sw $s1, 4($sp)
    sw $s2, 8($sp)
    sw $s3, 12($sp)

# Setup
    
    add $s0, $a0, $a1                          # inrement base address up to the current index
    lbu $s1, 0($s0)                             # Load byte unsigned at base_addr[start_index]  #FIXED BUG HERE
    addi $s2, $a1, 1                            # New starting index == old starting index + 1
   
# Body

    beqz $s1, end_of_expression                 # if null_terminator, return 0 in $v1

    li $t0, 40                                  # if left_bracket -> check next character
    beq $s1, $t0, check_next_leftbracket

    li $t0, 41                                  # if right_bracket -> check next character
    beq $s1, $t0, check_next_rightbracket

    # Calling valid_op

    addi $sp, $sp, -4                           # save return address
    sw $ra, 0($sp)

    move $a0, $s1                               # move current character into $a0
    jal valid_ops                               # make function call
    move $s3, $v0                               # move return value into register $s3

    lw $ra, 0($sp)
    addi $sp, $sp, 4                            # restore return address

    li $t0, 1
    beq $s3, $t0, check_next_operator           # if valid_operator -> check next character

    # If valid_op returns true then we go to check_operator, else continue to check digit

    addi $sp, $sp, -4                           # save return address
    sw $ra, 0($sp)

    move $a0, $s1                               # load character into function arguement
    jal is_digit                                # call is_digit ($s1)
    move $s3, $v0                               # move the return value into $s3

    lw $ra, 0($sp)                              
    addi $sp, $sp, 4                            # restore return address

    li $t0, 1
    addi $s1, $s1, -48                            # Get integer value of $s1, in case it is an integer
    beq $s3, $t0, check_next_digit

    # If program has reached this point, then we must have an invalid character

    j print_bad_token_message

check_next_digit:
    addi $s0, $s0, 1                            # increment our expressions base by 1
    lbu $s3, 0($s0)                             # load next character in expression into $s3

    addi $sp, $sp, -4                           # calling check_valid_character
    sw $ra, 0($sp)

    move $a0, $s3				# calling is_digit
    jal is_digit
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    beqz $v0, next_token_done                   # if it's an invalid token or not a digit, we can just return, if it's

    li $t0, 10
    mul $s1, $s1, $t0                           # Multiply $s1 by 10, then get integer of $s3 and
    addi $s3, $s3, -48                          # add it to $s1 to get our new result
    add $s1, $s1, $s3

    addi $s2, $s2, 1                            # increment to counter -> have to do this last
    j check_next_digit                          # jump back up to the top and check the next digit

check_next_operator:
    lbu $t0, 1($s0) 
    li $t1, 40  
    beq $t0, $t1, next_token_done               # if operator is followed by a left bracket -> return

    addi $sp, $sp, -4                           # expression and return are in $s registers, so
    sw $ra, 0($sp)                              # we can just save return address

    lbu $a0, 1($s0)                             # load next char into function arguement

    jal check_valid_character                  

    beqz $v0, print_bad_token_message           # if next character is not a valid token -> print invalid token
    
    li $t0, 4
    beq $v0, $t0, print_parse_error_message	# if next character is another operator -> parse error

    li $t0, 3
    beq $v0, $t0, print_parse_error_message	# if next character is a right bracket -> parse error
    						
    						# else we have a valid next character
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    j next_token_done                           # if next_char is a left bracket or digit -> return

check_next_leftbracket:
    addi $sp, $sp, -4                           # save return address to the stack
    sw $ra, 0($sp)

    lbu $a0, 1($s0)                             # load next character in our expression
    jal check_valid_character
    
    beqz $v0, print_bad_token_message         	# if next character is invalid -> print bad token

    li $t0, 4
    beq $v0, $t0, print_parse_error_message	# if next token is an operator -> print parse error
    
    li $t0, 3
    beq $v0, $t0, print_parse_error_message	# if next token is a right bracket -> print parse error
    
    lw $ra, 0($sp)
    addi $sp, $sp 4

    j next_token_done

check_next_rightbracket:
    lbu $t0, 1($s0)                             # if right_bracket followed by null term -> return
    beqz $t0, next_token_done

    addi $sp, $sp, -4                           # save $ra to the stack
    sw $ra, 0($sp)

    lbu $a0, 1($s0)                             # if next_char is operator -> return

    jal check_valid_character                   # else -> throw parse_error

    beqz $v0, print_bad_token_message 		# if next is invalid token -> print bad token message

    li $t0, 2
    beq $v0, $t0, print_parse_error_message	# if next is left_bracket -> print parse error message
    
    li $t0, 1
    beq $v0, $t0, print_parse_error_message	# if next is digit -> print parse error message
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    j next_token_done   

end_of_expression:
  li $s2, 0                                    # if we encounter null term -> return 0 in $v1  

next_token_done:

# Postamble

    move $v0, $s1                               # move our results into return addresses
    move $v1, $s2

    lw $s0, 0($sp)                              # restore values
    lw $s1, 4($sp)
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    addi $sp, $sp, 16                           # increment stack

    jr $ra                                      # return

#---------------------------------------------------------------------------------------#
#
# right_bracket -> handles the case when we get a right bracket as our next token. We
#
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
  sw $v1, 16($sp)			   # Update top of the operator stack

  li $t0, 40                               # if top_of_stack == 40 ('(') -> then we're done
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

  move $a0, $s2                             # first integer == $s2
  move $a1, $s0                             # operator == $s0
  move $a2, $s1                             # second integer == $s1

  jal apply_bop                             # apply our operator to the values

  move $a0, $v0                             # push $v0 back to value stack 
  lw $a1, 12($sp)                           # Load top of the value stack -> arg2
  lw $a2, 20($sp)                           # Load address of the value stack -> arg3

  jal stack_push                            # function call

  sw $v0, 12($sp)                           # adjust the top of the value stack

  j right_bracket_loop                      # go back to the start of the loop, must find left bracket
  
  right_bracket_post:
  
    lw $v0, 12($sp)			    # Return top of value stack in $v0
    lw $v1, 16($sp)			    # Return top of operator stack in $v1
    
    lw $s0, 0($sp) 			    # Restore values of the $s registers
    lw $s1, 4($sp) 
    lw $s2, 8($sp)  

    lw $a0, 12($sp) 			    # Don't think we need to restore these registers, but I did it anyway
    lw $a1, 16($sp)  
    lw $a2, 20($sp)
    lw $ra, 24($sp)			    # Definitly need to restore $ra
	
    addi $sp, $sp, 28 			    # Adjust stack pointer
    
    jr $ra                      	    # return

#---------------------------------------------------------------------------------------#
