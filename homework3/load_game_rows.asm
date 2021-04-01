#---------------------------------------------------------------------------------------------------------------------------#

load_game_rows:		# $a0 -> the file descriptor, $a1 -> the current game-state structure

	addi $sp, $sp, -24				# allocating stack space
	sw $s0, 0($sp)					# $s0 -> running total of stones found
	sw $s1, 4($sp)					# $s1 -> running total of pockets
	
	sw $s2, 8($sp)					# $s2 -> temp sum of pocket
	sw $s3, 12($sp)					# $s3 -> temp base address of game-state
			
	sw $s4, 16($sp)					# $s4 -> copy of file descriptor
	sw $s5, 20($sp)					# $s5 -> copy of game-state structure

# Setup

	addi $sp, $sp, -4				# allocate stack space for the first character
	add $s0, $0, $0					# total_stones = 0
	add $s1, $0, $0					# total_pockets = 0
	
	move $s3, $a1					# copy game-state address into $s3
	addi $s3, $s3, 8				# increment to address of first row in game state structure
	
	move $s4, $a0					# copy file descriptor to $s4
	move $s5, $a1					# copy game-state address into $s4
	
# Main loop

load_rows_loop:

	move $a0, $s4					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	lbu $t0, 0($sp)
	li $t1, '\n'
	beqz $v0, load_rows_loop_done			# if we hit end of file -> then the loop is done
	beq $t0, $t1, load_rows_loop			# if we hit a newline -> skip to next iteration
	
	addi $sp, $sp, -4				# allocate stack space for the second character

load_rows_second_char:

	move $a0, $s4					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	lbu $t0, 0($sp)
	li $t1, '\n'
	beqz $v0, load_rows_loop_done			# if we hit end of file -> then the loop is done
	beq $t0, $t1, load_rows_second_char		# if we hit a newline -> pick up the next character
	
	# 0($sp) -> digit in one's place, 4($sp) -> digit in ten's place
	
	lbu $s2, 0($sp)					# load digit in one's place
	sb $s2, 1($s3)					# store byte to game state structure
	
	addi $s2, $s2, -48				# convert to integer
	
	lbu $t0, 4($sp)					# load digit in ten's place
	sb $t0, 0($s3)					# store byte to game state structure
	
	addi $t0, $t0, -48				# covert to integer
	li $t1, 10
	mul $t0, $t0, $t1				# multiply digit in ten's place by 10
	add $s2, $s2, $t0				# add ten's place value to temp sum
	add $s0, $s0, $s2				# add temp sum to running stones total
	
	
	addi $s3, $s3, 2				# increment base address by 2 -> go to next pocket
	addi $s1, $s1, 1				# add to total number of pockets found
	addi $sp, $sp, 4				# adjust stack pointer
	
	j load_rows_loop
	
load_rows_loop_done:
	
	addi $sp, $sp, 4				# deallocate stack space
	
	move $v0, $s0					# return total stones in $v0
	move $v1, $s1					# return total pockets in $v1
	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	
	addi $sp, $sp, 24
	
	jr $ra

#---------------------------------------------------------------------------------------------------------------------------#
