#---------------------------------------------------------------------------------------------------------------------------#
	
write_board:		# $a0 -> the current game state

	addi $sp, $sp, -12
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> copy of the game-state
	sw $s1, 8($sp)					# $s1 -> copy of the file descriptor
	
	sw $s2, 12($sp)					# $s2 -> loop counter variable == 2 * row_size
	sw $s3, 16($sp)					# $s3 -> loop counter variable == 4 * row_size
	
	move $s0, $a0					# save a copy of base address of the game-state
	
	jal write_board_get_descriptor			# get file descriptor for file called "output.txt"
	
	li $t0, -1					# if there's an error getting descriptor -> return -1
	beq $v0, $t0, write_board_file_error		# else -> continue
							
	move $s1, $v0					# move file descriptor to $s1
	
	# Write the top mancala to the file
	
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 6($s0)					# arg2 -> ten's place digit of top mancala's total
	jal write_board_write_char			# write ten's place digit of top mancala
	
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 7($s0)					# arg2 -> one's place digit of top mancala's total
	jal write_board_write_char			# write one's place digit of top mancala
	
	move $a0, $s1					# arg1 -> file descriptor
	li $a1, '\n'					# arg2 -> newline character
	jal write_board_write_char			# write newline character to the file
	
	# Write the bottom mancala to the file
	
	li $t0, 4
	lbu $t1, 3($s0)					# load size of the rows
	mul $t1, $t1, $t0				# multiply row_size by 4 
	addi $t1, $t1, 8				# increment by 8
	add $t1, $s0, $t1				# get the last two bytes game state
	
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 0($t1)					# arg2 -> second to last byte in game-state
	jal write_board_write_char			# write ten's place digit of bottom mancala
		
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 1($t1)					# arg2 -> last byte in the game-state
	jal write_board_write_char			# write one's place digit of bottom mancala
	
	move $a0, $s1					# arg1 -> file descriptor
	li $a1, '\n'					# arg2 -> newline character
	jal write_board_write_char			# write newline character to output.txt
	
	# Setting up the loop
	
	li $t0, 2
	lbu $s2, 2($s0)					# load row size
	mul $s2, $s2, $t0				# multiply row_size * 2 -> get end of bytes in first row
	mul $s3, $s2, $t0				# multiply by 2 again -> get total characters to print out
	
	addi $s0, $s0, 8				# increment base address of game-state -> to start of first row
	
write_board_loop:

	beqz $s2, write_board_loop_nl			# if we've reached the end of the first row -> print a newline
	beqz $s3, write_board_loop_done			# if we've printed all the bytes -> we're done
	
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 0($s0)					# arg2 -> next character to print
	
	jal write_board_write_char			# write the next character to the file
	
	j write_board_loop_next

write_board_loop_nl:

	move $a0, $s1					# arg1 -> file descriptor
	li $a1, '\n'					# arg2 -> newline character
	
	addi $s2, $s2, -1				# make sure $s2 -> not equal to 0 again (infinite recursion)
	
	jal write_board_write_char			# write newline to the file
	j write_board_loop				# go back to the main loop

write_board_loop_next:
	addi $s2, $s2, -1
	addi $s3, $s3, -1
	addi $s0, $s0, 1
	
	j write_board_loop				# continue to next iteration
	
write_board_loop_done:
	li $v0, 1					# if we've written everything to the file -> return 1
	j write_board_done
	
write_board_file_error:					# if file error -> return -1
	li $v0, -1
	
write_board_done:

	move $a0, $s1					# close the file we are writing to
	li $v0, 16
	syscall
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#

write_board_write_char:		# $a0 -> file descriptor, $a1 -> character to write to the file
	
	addi $sp, $sp, -1				# allocate space on stack for our character
	sb $a1, 0($sp)					# store character to stack
	
	# move $a0, $a0
	move $a1, $sp					# using the stack as the memory buffer
	li $a2, 1					# read 1 character
	li $v0, 15					# writing to file
	syscall
	
	addi $sp, $sp, 1				# deallocate stack space
	
	jr $ra						# returns $v0 -> negative if there's an error, I'm assuming

#---------------------------------------------------------------------------------------------------------------------------#

write_board_get_descriptor:	# takes no arguments -> gets the file descriptor to write to file called "output.txt"

	addi $sp, $sp, -11 				# allocate stack space for filename...
	li $t0, 'o'
	li $t1, 'u'					# loading characters we need into $t registers
	li $t2, 't'
	li $t3, 'p'
	li $t4, 'x'
	li $t5, '.'
	li $t6, '\0'
	
	sb $t0, 0($sp)	# o				# I think you get what I'm doing here
	sb $t1, 1($sp)	# u
	sb $t2, 2($sp)	# t
	sb $t3, 3($sp)	# p
	sb $t1, 4($sp)	# u
	sb $t2, 5($sp)	# t
	sb $t5, 6($sp)	# .
	sb $t2, 7($sp)	# t
	sb $t4, 8($sp)	# x
	sb $t2, 9($sp)	# t
	sb $t6, 10($sp) # \0

	# base address of the filename is now at $sp, I'm pretty sure
	
	move $a0, $sp					# load address of the filename
	li $a1, 1					# open file for writing
	li $a2, 0					# ignore the mode
	li $v0, 13					# get file descriptor
	syscall
	
	addi $sp, $sp, 11				# deallocate stack spaced used for filename
	
	jr $ra						# return file descriptor in $v0
							
#---------------------------------------------------------------------------------------------------------------------------#
