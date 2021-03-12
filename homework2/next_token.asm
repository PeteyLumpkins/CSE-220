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
    lbu $s1, 0($s0)                             # Load byte unsigned at base_addr[start_index]
    addi $s2, $a1, 1                            # New starting index == old starting index + 1

# Body

    beqz $s1, next_token_done                   # if null_terminator, then just return it

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

    j print_parse_error_message

check_next_digit:
    addi $s0, $s0, 1                            # increment our expressions base by 1
    lbu $s3, 0($s0)                             # load next character in expression into $s3

    addi $sp, $sp, -4                           # calling is_digit
    sw $ra, 0($sp)

    move $a0, $s3
    jal is_digit
    
    lw $ra, 0($sp)
    addi $sp, $sp, 4

    beqz $v0, next_token_done                   # if it's not a digit, we can just return, if it's
                                                # invalid or anything else, next iteration will pick it up

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

    jal is_digit                                # if next character is not a digit or a left bracket                                 
    beqz $v0, print_parse_error_message         # then it's a parse error, else we're good

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    j next_token_done                           # if next_char is a left bracket or digit -> return

check_next_leftbracket:
    addi $sp, $sp, -4                           # save return address to the stack
    sw $ra, 0($sp)

    lbu $a0, 1($s0)                             # load next character in our expression
    jal is_digit
    
    beqz $v0, print_parse_error_message         # if next character is not a digit, then ill-formed

    lw $ra, 0($sp)
    addi $sp, $sp 4

    j next_token_done

check_next_rightbracket:
    lbu $t0, 1($s0)                             # if right_bracket followed by null term -> return
    beqz $t0, next_token_done

    addi $sp, $sp, -4                           # save $ra to the stack
    sw $ra, 0($sp)

    lbu $a0, 1($s0)                             # if next_char is operator -> return

    jal valid_ops                                # else -> throw parse_error

    beqz $v0, print_parse_error_message 

    lw $ra, 0($sp)
    addi $sp, $sp, 4

    j next_token_done     

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
