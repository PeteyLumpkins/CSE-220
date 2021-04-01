#---------------------------------------------------------------------------------------------------------------------------#

load_game:						# $a0 -> starting address of game state structure $a1 -> game filename
	
# Preamble

	addi $sp, $sp, -24				# Allocating stack space
	sw $ra, 0($sp)					# Saving return address
	sw $s0, 4($sp)					# $s0 -> holds the base address of game structure
	sw $s1, 8($sp)					# $s1 -> holds the file descriptor
	sw $s2, 12($sp)					# $s2 -> total stones we have in the game
	sw $s3, 16($sp)					# $s3 -> holds modified starting address of the gamee state
	sw $s4, 20($sp)					# $s4 -> is going to be our running count of the # of pockets
	
# Setting up the file to read from, initializing variables, etc.

	move $s0, $a0					# We need to hang onto the value in $a0 -> storing a copy in $s0
	move $s2, $0					# total_stones = 0
	move $s4, $0					# total_pockets = 0

	move $a0, $a1					# loading function arguement with base address of file to open
	li $a1, 0					# setting flag to read only access
	li $v0, 13				
	syscall
	
	li $t0, -1
	beq $v0, $t0, invalid_input_file		# if file descriptor is negative -> return (-1, -1)
	move $s1, $v0					# save file descriptor in $s1
	
# Reading and loading in the first 3 lines of the file -> top manncala, bottom mancala, row size
	
	move $a0, $s1					# arg1 -> file descriptor
	jal load_next_byte				# get stones in top mancala
	add $s2, $s2, $v0				# increment total stones
	sb $v0, 1($s0)					# store the stones at the top of mancala in game state

# Storing characters in the top mancala to the game string
	
	li $t0, 10
	div $v0, $t0					# we want to get the character values of the top mancala
	
	mflo $t0					
	addi $t0, $t0, 48				# get character value of digit in ten's place
	sb $t0, 6($s0)					# store the character in ten's place to game string
	
	mfhi $t0
	addi $t0, $t0, 48				# get character value of digit in one's place
	sb $t0, 7($s0)					# store the characteer in one's place to game string
	
	move $a0, $s1					# arg1 -> file descriptor 
	jal load_next_byte				# get stones in bottom mancala
	add $s2, $s2, $v0				# incremeent total stones
	sb $v0, 0($s0)					# store the stones at the bottom of mancala in game state
	
	move $a0, $s1					# arg1 -> file descriptor
	jal load_next_byte				# get the row size
	sb $v0, 2($s0)					# store bottom row size
	sb $v0, 3($s0)					# store top row size
	
# Storing characters in the bottom mancala to the gamee string
	
	lbu $t0, 3($s0)					# get row size of the game-state
	li $t1, 4					# we want to get the index of the bottom mancala in the game string
	mul $t0, $t0, $t1				# index bottom mancala == ( 2 * 2 * row_size) + 8
	addi $t0, $t0, 8				# add 8 to result of 4 * row_size
	add $t0, $s0, $t0				# get temporary address of the game string
	
	li $t1, 10					# we want to get the characters of bottom mancala
	lbu $t2, 0($s0)					# get bottom mancala
	div $t2, $t1					# divide the value by 10
	
	mflo $t1
	addi $t1, $t1, 48				# get character value of the 10's place digit
	sb $t1, 0($t0)					# store ten's place digit of the top mancala
	
	mfhi $t1	
	addi $t1, $t1, 48				# get character value of 1's place digit
	sb $t1, 1($t0)					# store one's place digit of bottom mancala
	
# Loading and storing the top and bottom rows of the game to the game-state

	move $a0, $s1					# arg1 -> file descriptor
	move $a1, $s0					# arg2 -> game-state
	jal load_game_rows				# loads the rows from the file into the game state structure

	add $s2, $s2, $v0				# add the stones to the total stones found
	move $s4, $v1					# gets the total number of pockets -> moves them into $s4	
	
# At this point the entire game has been initialized, except for the moves taken and the players turn
	
	
	


	
invalid_input_file:					# if the file is invalid for some reasone return -> (-1, -1)
	li $v0, -1
	li $v1, -1
	j load_game_done
	
load_game_done:

	
	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $ra, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#
