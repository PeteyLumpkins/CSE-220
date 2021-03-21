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
  sw $s1, 4($sp)                  # save register $s1 to the stack 

# Body

  addi $s0, $a0, -4               # calculate where are element is on our stack
  li $s1, -4

  ble $s0, $s1, stack_peek_underflow    # if our position is less than -4, than we have underflow

  add $v0, $a1, $s0               # get position of the top of the stack
  lw $v0, 0($v0)                  # move value at the top of the stack into $v0 (funky I know -> saved a register tho)
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

  addi $sp, $sp, -8             # allocate space on the stack
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

# The following "methods" are here for printing error messages. After an error message
# is printed the program terminates by jumping to the terminate_program label.

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
# The following methods are actual helper methods. The first method, check_valid_character
# figures out whether a character is valid, and returns an integer that corresponds to what
# that valid character is.
#
# The rest of the methods are to handle cases in the eval function, depending on what the
# next token in the expression we want to evaluate is.
#
#---------------------------------------------------------------------------------------#

check_valid_character:	# checks if the given character is a valid character or not

			# takes one arguements, $a0 -> the character to validate
	
	addi $sp, $sp, -8					# save the value of $s0 to the stack
	sw $s0, 0($sp)				
	sw $ra, 4($sp)
	
	li $s0, 40
	beq $a0, $s0, valid_character_leftbracket			# if char is '(' -> then return valid
	
	li $s0, 41
	beq $a0, $s0, valid_character_rightbracket	        		# if char is ')' -> then return valid
	
	move $s0, $a0						# move $a0 into $s0 -> prevserving value
	
	# arg1 = $a0 -> should still be our character
	# also -> return address has already been saved to the stack
	
	jal valid_ops						# call valid ops on $a0 (our character)
	
	li $t0, 1
	beq $v0, $t0, valid_character_operator  			# if char is valid_op -> then return valid
	
	move $a0, $s0

	jal is_digit						# call is_digit
	
	li $t0, 1
	beq $v0, $t0, valid_character_digit			# if char is_digit -> then return valid
	
	j invalid_character					# else -> character must be invalid
	
valid_character_operator:						# if character is an operator -> return 4
	li $v0, 4
	j valid_character_done
	
valid_character_rightbracket:					# if valid char is a right bracket -> return 3
	li $v0, 3
	j valid_character_done
	
valid_character_leftbracket:					# if valid char is a left bracket -> return 2
	li $v0, 2
	j valid_character_done
	
valid_character_digit:						# if valid char is a digit -> return 1
	li $v0, 1
	j valid_character_done
	
invalid_character:						# if char is invalid -> return 0
	li $v0, 0
	
valid_character_done:

	lw $s0, 0($sp)		    # restore values from the stack
	lw $ra, 4($sp)		    # restore return address
	addi $sp, $sp, 8
	
	jr $ra			    # if valid and digit -> 1, if valid and left_bracket -> 2 
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

addi $sp, $sp, -28		    # Allocating stack space

sw $s0, 0($sp)                      # Stores next operator on the op_stack
sw $s1, 4($sp)                      # Stores the first value popped off the value stack
sw $s2, 8($sp)                      # Stores the precedence of the current operator
sw $ra, 24($sp)                     # Save our return address (we're going to be making some function calls)

# Setup -> we need to make some "backup" copies of our function arguements

sw $s3, 12($sp)			    # Saves the current operator we want to push to the top of the op_stack
move $s3, $a0

sw $s4, 16($sp)			    # Saves the top of the value stack
move $s4, $a1

sw $s5, 20($sp)			    # Saves the top of the operator stack
move $s5, $a2

# $a0 is our function arguement, so no need to load function args for op_precedence (they're already loaded)

jal op_precedence                   # make function call

move $s2, $v0                       # move operator precedence into $s2 -> save it for later

# Body

operator_loop:

    move $a0, $s5                 # Load the top of operator stack -> check if stack is empty

    jal is_stack_empty              # Calling stack_is_empty

    li $t0, 1                       # if op_stack is empty -> then we just push our operator onto the op stack
    beq $v0, $t0, operator_done

    move $a0, $s5                 # else -> peek the top of the stack, and get precedence of top operator
    la, $a1, op_stack
    addi $a1, $a1, 2000             # Offsetting top of the operator stack

    jal stack_peek                  # Call to stack_peek
    
    li $t0, 40
    beq $v0, $t0, operator_done	    # if the item on the top of the stack is a left bracket -> then we're done

    move $a0, $v0                   # Move operator at top of the stack into $a0 -> call op_precedence

    jal op_precedence               # Call to op_precedence

    blt $v0, $s2, operator_done     # if top_of_stack < current_operator -> then push current operator

    # else we pop operator off the top of the stack, pop two values off of 
    # the value stack and push result back to value stack, then we go back through the loop

    move $a0, $s5                  # Load top of operator stack into $a0
    la $a1, op_stack               # Load base address into $a1
    addi $a1, $a1, 2000		   # Offset the initial address of the op_stack by 2000

    jal stack_pop                  # Make function call

    move $s5, $v1                  # Save new top of the operator stack
    move $s0, $v0                  # Save current operator in $s0

    move $a0, $s4                  # Load top of value stack into $a0
    la $a1, val_stack              # Load address of value stack into $a1

    jal stack_pop                  # Pop first value off the value stack

    move $s4, $v1                  # Store the new top of the value stack 
    move $s1, $v0                  # Move the first operand into $s1

    move $a0, $s4                  # Load top of the value stack into $a0
    la $a1, val_stack              # Load address of the value stack into $a1

    jal stack_pop                  # Pop second value off the value stack

    move $s4, $v1                  # Save the new top of the value stack

    move $a0, $v0                  # Apply binary operator to our two operands
    move $a1, $s0
    move $a2, $s1

    jal apply_bop                  # Apply the bop

    move $a0, $v0                  # Move the result into $a0 and push it back to the value stack
    move $a1, $s4                  # Load the top of the value stack
    la $a2, val_stack              # Address of the value stack

    jal stack_push

    move $s4, $v0                  # Update the new top of the value stack

    j operator_loop                # Go to the next loop iteration

operator_done:

    move $a0, $s3                        # Load operator into arg1
    move $a1, $s5                        # Load top of operator stack into arg2

    la $a2, op_stack                     # Load base address of operator stack into arg3
    addi $a2, $a2, 2000

    jal stack_push                       # Push operator onto the stack

    move $s5, $v0                        # Update the current top of the operator stack

# Load return values into $v0 and $v1

    move $v0, $s4                        # Return top of value stack at $v0
    move $v1, $s5                        # Return top of operator stack at $v1

# Postamble

    lw $ra, 24($sp)                      # Restore return address

    lw $s0, 0($sp)                       # Restore the values of the $s registers
    lw $s1, 4($sp) 
    lw $s2, 8($sp)
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    
    addi $sp, $sp, 28			# Deallocate stack space
    
    jr $ra                              # Return

#---------------------------------------------------------------------------------------#
#
# next_token -> collects and builds the next token from our expression string whether it
#		is an operator or an operand. Also checks the format of the expression is
#		valid
#
#---------------------------------------------------------------------------------------#

next_token:         # $a0 == base address of the equation   # $a1 == starting index of the next token

# Preamble

    addi $sp, $sp, -20
    sw $s0, 0($sp)
    sw $s1, 4($sp)				# The next token (return value for $v0)
    sw $s2, 8($sp)				# Save the starting index of the next token (return value for $v1)
    sw $s3, 12($sp)
    
    sw $ra, 16($sp)				# Saving return address
    
# Setup
    
    add $s0, $a0, $a1                           # inrement base address up to the current index
    lbu $s1, 0($s0)                             # Load byte unsigned at base_addr[start_index]  #FIXED BUG HERE
    addi $s2, $a1, 1                            # New starting index == old starting index + 1
   
# Body

    beqz $s1, end_of_expression                 # if null_terminator, return 0 in $v1

    li $t0, 40                                  # if left_bracket -> check next character
    beq $s1, $t0, check_next_leftbracket

    li $t0, 41                                  # if right_bracket -> check next character
    beq $s1, $t0, check_next_rightbracket

    # Calling valid_op

    move $a0, $s1                               # move current character into $a0
    jal valid_ops                               # make function call
    move $s3, $v0                               # move return value into register $s3

    li $t0, 1
    beq $s3, $t0, check_next_operator           # if valid_operator -> check next character

    # If valid_op returns true then we go to check_operator, else continue to check digit

    move $a0, $s1                               # load character into function arguement
    jal is_digit                                # call is_digit ($s1)
    move $s3, $v0                               # move the return value into $s3

    li $t0, 1
    addi $s1, $s1, -48                          # Get integer value of $s1, in case it is an integer
    beq $s3, $t0, check_next_digit

    # If program has reached this point, then we must have an invalid character

    j print_bad_token_message

check_next_digit:
    addi $s0, $s0, 1                            # increment our expressions base by 1
    lbu $s3, 0($s0)                             # load next character in expression into $s3

    move $a0, $s3				# calling is_digit
    jal is_digit

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

    lbu $a0, 1($s0)                             # load next char into function arguement

    jal check_valid_character                  

    beqz $v0, print_bad_token_message           # if next character is not a valid token -> print invalid token
    
    li $t0, 4
    beq $v0, $t0, print_parse_error_message	# if next character is another operator -> parse error

    li $t0, 3
    beq $v0, $t0, print_parse_error_message	# if next character is a right bracket -> parse error
    						# else we have a valid next character
    						
    j next_token_done                           # if next_char is a left bracket or digit -> return

check_next_leftbracket:
    lbu $a0, 1($s0)                             # load next character in our expression
    jal check_valid_character
    
    beqz $v0, print_bad_token_message         	# if next character is invalid -> print bad token

    li $t0, 4
    beq $v0, $t0, print_parse_error_message	# if next token is an operator -> print parse error
    
    li $t0, 3
    beq $v0, $t0, print_parse_error_message	# if next token is a right bracket -> print parse error

    j next_token_done

check_next_rightbracket:
    lbu $t0, 1($s0)                             # if right_bracket followed by null term -> return
    beqz $t0, next_token_done

    lbu $a0, 1($s0)                             # if next_char is operator -> return

    jal check_valid_character                   # else -> throw parse_error

    beqz $v0, print_bad_token_message 		# if next is invalid token -> print bad token message

    li $t0, 2
    beq $v0, $t0, print_parse_error_message	# if next is left_bracket -> print parse error message
    
    li $t0, 1
    beq $v0, $t0, print_parse_error_message	# if next is digit -> print parse error message

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
    
    lw $ra, 16($sp)				# restore return address
    
    addi $sp, $sp, 20                           # increment stack

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

addi $sp, $sp, -28                         # Allocating stack space here

sw $s0, 0($sp)                             # Operator popped off the operator stack
sw $s1, 4($sp)				   # First value popped off the value stack
sw $s2, 8($sp)				   # Second value popped off the value stack

# I need to save some backup copies of my function arguements here -> not sure how else to do it

sw $s3, 12($sp)				   # Top of value stack
move $s3, $a0				   # $s3 == top of the value stack

sw $s4, 16($sp)				   # Top of operator stack
move $s4, $a1				   # $s4 == top of the operator stack

sw $s5, 20($sp)				   # Address of value stack
move $s5, $a2				   # $s5 == base address of the value stack

sw $ra, 24($sp)                            # Return address

# Now we can start the main loop here

right_bracket_loop:

# First we check if the operator stack is empty, if so then there's a problem (should be a left bracket somewhere)

  move $a0, $s4                            # Load top of operator stack as function arg

  jal is_stack_empty                       # Function call

  li $t0, 1
  beq $v0, $t0, print_parse_error_message  # if op_stack is empty -> parse error 

# Calling the pop function on the operator stack to get initial value on the top of the stack

  move $a0, $s4                         # Top of operator stack -> arg1
  move $a1, $a3                            # Address of operator stack -> arg2

  jal stack_pop                            # Function call

  move $s0, $v0                            # Move operator into register $s0 -> save for later
  move $s4, $v1 		           	# Update top of the operator stack

  li $t0, 40                               # if top_of_stack == 40 ('(') -> then we're done
  beq $s0, $t0, right_bracket_post         # else -> pop 1 op, pop 2 values, push 1 value

# If our top of the stack is not a left bracket, we have to pop two values off of the value stack,
# apply the operator at 0 to them, and push the result back to the stack

  move $a0, $s3                             # Load top of the value stack -> arg1
  move $a1, $s5                             # Load address of value stack -> arg2

  jal stack_pop                             # Function call

  move $s1, $v0                             # Move first value into register $s1 -> save for later
  move $s3, $v1                             # Adjust/Replace top of the value stack

  move $a0, $s3                             # Make another call to stack_pop to
  move $a1, $s5                             # get the second value

  jal stack_pop                             # Function call

  move $s2, $v0                             # Move second value into register $s2 -> save for later
  move $s3, $v1                             # Adjust top of the val_stack

  move $a0, $s2                             # first integer == $s2
  move $a1, $s0                             # operator == $s0
  move $a2, $s1                             # second integer == $s1

  jal apply_bop                             # apply our operator to the values

  move $a0, $v0                             # push $v0 back to value stack 
  move $a1, $s3                             # Load top of the value stack -> arg2
  move $a2, $s5                             # Load address of the value stack -> arg3

  jal stack_push                            # function call

  move $s3, $v0                             # adjust the top of the value stack

  j right_bracket_loop                      # go back to the start of the loop, must find left bracket
  
  right_bracket_post:
  
    move $v0, $s3			    # Return top of value stack in $v0
    move $v1, $s4			    # Return top of operator stack in $v1
    
    lw $s0, 0($sp) 			    # Restore values of the $s registers
    lw $s1, 4($sp) 
    lw $s2, 8($sp)  
    lw $s3, 12($sp)
    lw $s4, 16($sp)
    lw $s5, 20($sp)
    
    lw $ra, 24($sp)			    # Definitly need to restore $ra

    # I did not restore the values of the $a0 registers because I don't think we have to
	
    addi $sp, $sp, 28 			    # Deallocate stack space 
    
    jr $ra                      	    # return $v0 == top of val_stack, $v1 == top of op_stack

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
  
  move $a0, $s1				  # Before we try to pop two values off the value stack we need to make sure there
  					  # are two values on the stack -> so I'm going to decrement $a0 by 4...	  
  addi $a0, $a0, -4			  # I think my logic makes sense here
  
  jal is_stack_empty
  
  li $t0, 1
  beq $v0, $t0, print_parse_error_message # if value stack is empty and operator stack is not empty -> print parse error!

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
  
  move $a0, $v0
  li $v0, 1
  syscall
  

  jr $ra                                  # returns nothing

#---------------------------------------------------------------------------------------#
