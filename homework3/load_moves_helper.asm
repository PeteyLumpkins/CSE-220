#---------------------------------------------------------------------------------------------------------------------------#

load_moves_helper:		# $a0 -> file descripter, $a1 -> byte array, $a2 -> row size

	addi $sp, $sp, -28	
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> copy of file descriptor		
	sw $s1, 8($sp)					# $s1 -> copy of byte array
	sw $s2, 12($sp)					# $s2 -> copy of the row size
	sw $s3, 16($sp)					# $s3 -> temp value of the row size
	sw $s4, 20($sp)					# $s4 -> rows encountered
	sw $s5, 24($sp)					# $s5 -> items added to the byte array
	
	move $s0, $a0					# save copy of file descriptor
	move $s1, $a1					# save copy of base address of byte array
	move $s2, $a2					# save copy of the row size
	move $s3, $s2					# set temp value of row size -> row size
	and $s4, $0, $0					# initialize rows seen to 0
	and $s5, $0, $0					# initialize total moves added to array to 0
	
	addi $sp, $sp, -4				# make space on the stack for the next character

load_moves_helper_loop:

	beqz $s3, load_moves_next_row			# if we've inserted a row -> insert 99 and continue iterating
							
	# Get the digit in the tens place -> move that value into $s1
	
	move $a0, $s0					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	beqz $v0, load_moves_helper_done		# if end of file -> move to done (shouldn't be the case)
	
	li $t0, '\n'
	lbu $t1, 0($sp)
	beq $t0, $t1, load_moves_helper_done		# if we've reached the end of the line -> then we're done
	
	# Get the digit in the ones place -> add that value to $s1
	
	addi $sp, $sp, -4				# allocate stack space for next character
	
	move $a0, $s0					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall

	# Check if both of the characters are valid
	
	lbu $a0, 0($sp)					# load ones place digit
	jal is_digit
	beqz $v0, load_moves_invalid_move		# if character is not a digit -> add -1 to byte array
	
	lbu $a0, 4($sp)					# load tens place digit
	jal is_digit
	beqz $v0, load_moves_invalid_move		# if character is not a digit -> add -1 to byte array
	
	# If both characters are valid, we can safely get their integer values and append them to the byte string
	
	lbu $t0, 4($sp)					# get the digit in the ten's place
	addi $t0, $t0, -48				# get integer value of digit
	li $t1, 10
	mul $t0, $t0, $t1				# multiply digit in ten's place by 10
	
	lbu $t1, 0($sp)					# get the digit in the one's place
	addi $t1, $t1, -48				# get integer value of digit
	
	add $t0, $t0, $t1				# add the ten's place and the one's place together
	sb $t0, 0($s1)					# store the result to the byte array
	
	j load_moves_next_char
	
load_moves_next_row:					# if we've hit the end of the row -> insert 99
	addi $s4, $s4, 1				# increment rows seen by 1
	bge $s4, $s2, load_moves_helper_done 		# if we've seen (row_size - 1) rows -> exit
	
	li $t0, 99
	sb $t0, 0($s1)					# store the 99
	addi $s1, $s1, 1				# increment base address of the moves array
	addi $s5, $s5, 1				# add one to total
	move $s3, $s2					# reset the row size counter to the row size
	j load_moves_helper_loop
	
load_moves_invalid_move:				# if the move is invalid -> I want to store -1 in the byte array, easy to id
	li $t0, -1
	sb $t0, 0($s1)					# store at next position in the byte array

load_moves_next_char:
	addi $s3, $s3, -1				# decrement the temp row size
	addi $s1, $s1, 1				# increment base address of the string by 1
	addi $sp, $sp, 4				# adjust stack frame to get next characters
	addi $s5, $s5, 1				# add one to the total
	
	j load_moves_helper_loop 			# go to next loop iteration
	
load_moves_helper_done:

	addi $sp, $sp, 4				# deallocate the stack space for the memory buffer
	move $v0, $s5					# return items added to the byte array in $v0
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	addi $sp, $sp, 28
	
	jr $ra

#---------------------------------------------------------------------------------------------------------------------------#
