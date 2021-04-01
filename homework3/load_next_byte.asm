#---------------------------------------------------------------------------------------------------------------------------#

load_next_byte:	# $a0 -> the initial file pointer to the top of the mancala		# instructions < 50 roughly

	addi $sp, $sp, -8				# allocating stack space
	sw $s0, 0($sp)					# $s0 -> copy of $a0 (file pointer)
	sw $s1, 4($sp)					#
	
	move $s0, $a0					# preserving the file pointer 
	
	addi $sp, $sp, -4				# allocate stack space for buffer
	move $a0, $s0					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	addi $sp, $sp, -4				# allocate stack space for buffer
	move $a0, $s0					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	# 0($sp) == 1's place or '\n' and 4($sp) == one's place or ten's place
	
	li $t0, '\n'
	lw $t1, 0($sp)
	beq $t0, $t1, load_next_byte_single		# if 0($sp) == '\n' -> then we're dealiing with 4($sp) == total stones
	
	lw $s1, 4($sp)					# load ten's place digit
	addi $s1, $s1, -48				# get integer value of ten's place
	li $t0, 10
	mul $s1, $s1, $t0				# multiply result by 10
	lw $t0, 0($sp)
	addi $t0, $t0, -48				# get integer value of digit in one's place
	add $s1, $s1, $t0				# add ten's place and one's place together to get result
	
	move $a0, $s0					# before we return -> want to make 1 more call to read over the next
	move $a1, $sp					# newline character -> so that way we can skip it in the next func call
	li $a2, 1					
	li $v0, 14					
	syscall
	
	move $v0, $s1
	
	j load_next_byte_done
	
load_next_byte_single:				# if 4($sp) == '\n' -> we have < 10 stones in the mancala

	lw $v0, 4($sp)					# get the digit on the stack
	addi $v0, $v0, -48				# subtract 48 to get the decimal / integer value of the character

	# fall through to done
	
load_next_byte_done:	# $v0 -> the stones in the top, $v1 -> the new file pointer
	
	addi $sp, $sp, 8				# deallocate stack space used for reading characters from the file
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	jr $ra						# return, $v0 -> stones in top mancala $v1 -> new file pointer?
	
#---------------------------------------------------------------------------------------------------------------------------#
