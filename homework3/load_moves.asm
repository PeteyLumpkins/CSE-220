#---------------------------------------------------------------------------------------------------------------------------#

load_moves:		# $a0 -> base address of the byte array to store the moves, $a1 -> filename to read from

# Preamble
	addi $sp, $sp, -20
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> copy of file descripter
	sw $s1, 8($sp)					# $s1 -> number of columns in array
	sw $s2, 12($sp)					# $s2 -> number of rows in array
	sw $s3, 16($sp)					# $s3 -> base address of byte array			

	move $s3, $a0					# save a copy of the base address of the byte array
	
	move $a0, $a1					# arg1 -> filename
	li $a1, 0					# arg2 -> read-only flag
	li $v0, 13					# arg3 -> open-file
	syscall
	
	li $t0, -1
	beq $v0, $t0, load_moves_done			# if file error -> return $v0 = -1
	move $s0, $v0					# save a copy of the file descriptor to $s0
	
	move $a0, $s0					# arg1 -> file descriptor
	jal load_next_byte				# get the number of columns in the array
	move $s1, $v0					# $s1 = columns
	
	move $a0, $s0					# arg1 -> file descriptor
	jal load_next_byte				# get the number of rows in the array
	move $s2, $v0					# $s2 = rows

	move $a0, $s0					# arg1 -> file descripter
	move $a1, $s3					# arg2 -> base address of byte array
	move $a2, $s2					# arg3 -> number of rows
	
	jal load_moves_helper				# loads the characters into the byte array
	
load_moves_done:

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20				
	
	jr $ra						# return, $v0 -> total moves in the moves array 
	
#---------------------------------------------------------------------------------------------------------------------------#
