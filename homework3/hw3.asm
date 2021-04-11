# Peter Walsh
# ptwalsh
# 112599920

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

#---------------------------------------------------------------------------------------------------------------------------#

load_game:						# $a0 -> starting address of game state structure $a1 -> game filename
							# for the first example -> used ~600 instructions... pretty damn good I think
# Preamble

	addi $sp, $sp, -16				# Allocating stack space
	sw $ra, 0($sp)					# Saving return address
	sw $s0, 4($sp)					# $s0 -> holds the base address of game structure
	sw $s1, 8($sp)					# $s1 -> holds the file descriptor
	sw $s2, 12($sp)					# $s2 -> total stones we have in the game

# Setting up the file to read from, initializing variables, etc.

	move $s0, $a0					# We need to hang onto the value in $a0 -> storing a copy in $s0
	move $s2, $0					# total_stones = 0
	
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
	
	bltz $v0, invalid_input_file			# if there's a problem reading from the file -> return (-1, -1)
	
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

	move $a0, $s1					# closing the file
	li $v0, 16
	syscall

	li $t0, 99
	bgt $s2, $t0, load_game_invalid_stones		# if total_stones > 99 -> return $v0 = 0
	li $v0, 1					# else return $v0 = valid number of stones
	
	j load_game_check_pockets
				
load_game_invalid_stones:
	li $v0, 0					# if total_stones > 99 -> return $v0 = 0
							# fall through to check_pockets
load_game_check_pockets:
	
	li $t0, 98
	bgt $v1, $t0, load_game_invalid_pockets		# if total_pockets > 98 -> return $v1 = 0
	# move $v1, $v1					# else return $v1 = total_pockets -> return
	j load_game_done				

load_game_invalid_pockets:
	li $v1, 0					# if total_pockets > 98 -> return $v1 = 0
	j load_game_done				# return
	
invalid_input_file:					# if the file is invalid for some reason return -> (-1, -1)
	li $v0, -1
	li $v1, -1
	j load_game_done
	
load_game_done:

	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $ra, 0($sp)
	addi $sp, $sp, 16
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#

get_pocket:	# $a0 -> address of the gamestate, $a1 -> player (byte), $a2 -> distance (byte), roughly 40 instructions

# Preamble

	addi $sp, $sp, -8				# Save registers $s0 and $s1 to system stack
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	
# Body		

	lbu $s0, 3($a0)					# Load the number of pockets in the mancala
	addi $t0, $s0, -1				# add -1 to the row length, array indices == 0 -> (len - 1)
	bgt $a2, $t0, get_pocket_invalid		# If the distance > (row_size - 1) -> return -1 (error)
	
	li $t0, 'T'					# if row == 'T' -> get_top_pocket
	beq $a1, $t0, get_top_pocket
	
	li $t0, 'B'					# if row == 'B' -> get_bottom_pocket
	beq $a1, $t0, get_bottom_pocket
	
	j get_pocket_invalid				# else -> player is neither 'B' or 'T' -> return -1 (error)

get_top_pocket:

	# to get the index of the pocket along the top row in game state	 
	# we do -> (distance * 2) + 8
	
	li $t0, 2
	
	mul $s0, $a2, $t0				# distance * 2
	addi $s0, $s0, 8				# (distance * 2) + 8
	add $a0, $a0, $s0				# increment base index of the passed game structure
	
	j get_pocket_result

get_bottom_pocket:

	# to get the index of the pocket along the bottom row in the game state, we do -> (2 * (2 * row_size - distance) + 6)

	li $t0, 2
	mul $s0, $s0, $t0				# multiply row size by 2		2 * row_size
	sub $s0, $s0, $a2				# subtract row*2 - distance		2 * row_size - distance
	mul $s0, $s0, $t0				# multiply by two again		2 * (2 * row_size - distance)
	addi $s0, $s0, 6				# add 6 to the total
	
	add $a0, $a0, $s0				# increment base address of the game state by our result
	j get_pocket_result
	
get_pocket_result:

	lbu $s0, 0($a0)					# get character in tens place of pocket
	lbu $s1, 1($a0)					# get character in ones place of the pocket
	
	addi $s0, $s0, -48				# get integer value of char in ten's place
	li $t0, 10
	mul $s0, $s0, $t0				# multiply digit in ten's place by ten
	addi $s1, $s1, -48				# get integer value of digit in one's place
	add $v0, $s0, $s1				# add the one's place and ten's place integers together
	
	j get_pocket_done				# return the result in $v0
	
get_pocket_invalid:

	li $v0, -1					# if pocket is invalid -> return $v0 == -1

get_pocket_done:
	
# Postamble

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8				# Restore registers before returning
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#
	
set_pocket:	# $a0 -> starting address of game-state, $a1 -> player byte, $a2 -> byte distance, $a3 -> size

# Preamble

	addi $sp, $sp, -8				# Allocate stack frame space
	sw $s0, 0($sp)					# Let $s0 -> base address of the game to add our chars at
	sw $s1, 4($sp)					# Let $s1 -> temp digit for holding ASCII characters
	
# Body

	move $v0, $a3					# move size into return address -> might change if there are errors
	
	lbu $t0, 3($a0)					# load the size of the row into $t0
	addi $t0, $t0, -1				# if distance >= row_size - 1 -> error1
	bgt $a2, $t0, set_pocket_error1
	
	bltz $a2, set_pocket_error1 			# if distance < 0 -> error1
	
	li $t0, 99
	bgt $a3, $t0, set_pocket_error2			# if rocks_to_add > 99 -> error2
	
	bltz $a3, set_pocket_error2			# if rocks_to_add < 0 -> error2
	
	li $t0, 'B'
	beq $a1, $t0, set_bottom_pocket			# if player == 'B' -> set_bottom_pocket
	
	li $t0, 'T'					# if player == 'T' -> set_top_pocket
	beq $a1, $t0, set_top_pocket			
	
	j set_pocket_error1				# if player byte is not a valid player
	
set_top_pocket:
	
	li $t0, 2
	
	mul $s0, $a2, $t0				# distance * 2
	addi $s0, $s0, 8				# (distance * 2) + 8
	add $s0, $a0, $s0				# increment base index of the passed game structure
	
	j set_pocket_result
	
set_bottom_pocket:		# Increments the base address of the game state -> index of bottom pocket
	
	li $t0, 2
	lbu $s0, 2($a0)				# load row size into $s0
	
	mul $s0, $s0, $t0			# multiply row size by 2		2 * row_size
	sub $s0, $s0, $a2			# subtract row*2 - distance		2 * row_size - distance
	mul $s0, $s0, $t0			# multiply by two again		2 * (2 * row_size - distance)
	addi $s0, $s0, 6			# add 6 to the total
	
	add $s0, $a0, $s0			# increment base address of game state to the index of ten's place character
	j set_pocket_result	

set_pocket_error1:		# Error 1 -> returns $v0 == -1 -> invalid distance to pocket

	li $v0, -1
	j set_pocket_done

set_pocket_error2:		# Error 2 -> returns $v0 == -2 -> invalid value to add to pocket
	
	li $v0, -2
	j set_pocket_done
	
set_pocket_result:		# Takes our third arguement and saves the results to game state

	li $t0, 10
	div $a3, $t0					# we divide the new size value by 10
	
	mflo $s1					# move integer result of the division into $s0
	addi $s1, $s1, 48				# add 48 to $s1 -> get ASCII character value of digit
	sb $s1, 0($s0)					# store result of division to game string
	
	mfhi $s1					# move remainder result of division into $s1
	addi $s1, $s1, 48				# add 48 to $s1 -> get ASCII character value of remainder
	sb $s1, 1($s0)					# store result of remainder to game string
	
set_pocket_done:		# Postamble

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8

	jr $ra

#---------------------------------------------------------------------------------------------------------------------------#

collect_stones:		# $a0 -> base address of game state, $a1 -> player byte, $a2 -> rocks to add

# Preamble

	addi $sp, $sp, -8				# Saving a couple temp registers
	sw $s0, 0($sp)					# rocks in the top or bottom of the mancala
	sw $s1, 4($sp)
	
	move $v0, $a2					# Move potential return value in (could change, but doing it now)
	
	blez $a2, collect_stones_error2			# if stones <= 0 -> return error2 ($v0 == -2)
	
	li $t0, 'T'					# if player == 'T' -> collect_stones_top
	beq $a1, $t0, collect_stones_top
	
	li $t0, 'B'					# if player == 'B' -> collect_stones_bottom
	beq $a1, $t0, collect_stones_bottom
	
	j collect_stones_error1				# else player is an invalid character -> return error1 ($v0 == -1)
	
collect_stones_top:

	lb $s0, 1($a0)					# load number of rocks in top mancala
	add $s0, $s0, $a2				# add rocks to top of mancala
	sb $s0, 1($a0)					# save new total rocks in top of mancala
	
	addi $a0, $a0, 6				# move starting address of game string to top mancala
	
	j collect_stones_result				# compute the new number of stones in top of mancala

collect_stones_bottom:

	lb $s0, 0($a0)					# load number of rocks in bottom mancala
	add $s0, $s0, $a2				# add rocks to top of mancala
	sb $s0, 0($a0)					# store the new number of rocks in bottom of mancala
	
	li $t0, 4
	lbu $s1, 3($a0)					# get size of the bottom row 
	mul $s1, $s1, $t0				# multiply row size by 4
	addi $s1, $s1, 8				# add 8 to the total -> should get us to the last bytes of memory in the state
	add $a0, $a0, $s1				# increment base address of game state to the index of ten's place character

	j collect_stones_result				# compute new number of stones in top of mancala

collect_stones_error1:					# sets $v0 == -1 -> then returns
		
	li $v0, -1
	j collect_stones_done

collect_stones_error2:					# sets $v0 == -2 -> then returns

	li $v0, -2
	j collect_stones_done
	
collect_stones_result:

	li $t1, 10
	div $s0, $t1					# divide rocks in top of mancala by 10
	
	mflo $s0					# get the result of integer division of new top of mancala
	addi $s0, $s0, 48				# get ASCII of integer
	sb $s0, 0($a0)					# store character to ten's place of top mancala in the game string
	
	mfhi $s0					# get the remainder of the division of the new top of manncala
	addi $s0, $s0, 48				# get ASCII of remainder
	sb $s0, 1($a0)					# store character to one's place of top mancala in the game string
	
collect_stones_done:					# Postamble

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	addi $sp, $sp, 8
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#

verify_move:		# let $a0 == current game state, $a1 == origin_pocket of the move $a2 == distance of the move

# Preamble

	addi $sp, $sp, -16			# save registers to the stack frame
	sw $s0, 0($sp)				# Let $s0 == copy of game_state ($a0)
	sw $s1, 4($sp)				# Let $s1 == copy of the distance ($a2) 
	sw $s2, 8($sp)				# Let $s2 == copy of origin_pocket ($a1)
	sw $ra, 12($sp)				# making function calls -> so we save $ra at the top
	
# Body

	move $s0, $a0				# Save game state
	move $s1, $a2				# Save the distance
	move $s2, $a1				# Save origin pocket
	
	li $t0, 99				# if distance == 99 -> thenn return $v0 == 2
	beq $a2, $t0, verify_move_99
	
	# move $a0, $s0				# load gamestate into arg1
	lbu $a1, 5($s0)				# load current players turn into arg2
	move $a2, $s2				# load origin_pocket into $a2
	
	jal get_pocket				# getting number of stones in the origin_pocket
	
	beqz $v0, verify_move_done		# there are no stones in the origin_pocket -> so we can just return
	
	li $t0, -1
	beq $v0, $t0, verify_move_invalid1	# if get_pocket returns -1 -> then the move is invalid
	
	beqz $v0, verify_move_invalid0		# if the origin pocket -> contains no stones -> return 0
	
	bne $v0, $s1, verify_move_invalid2	# if the distance != number stones in origin pocket -> invalid move
	
	j verify_move_valid			# otherwise -> the move is valid, or should be that is...
	
verify_move_invalid0:
	
	li $v0, 1
	j verify_move_done			# if origin pocket -> contains no stones
	
verify_move_invalid1:

	li $v0, -1				# if origin pocket is an invalid pocket -> return $v0 == -1
	j verify_move_done	
	
verify_move_invalid2:

	li $v0, -2
	j verify_move_done			# if there's something wrong with the distance return -2
	
verify_move_valid:

	li $v0, 1				# if the move is a valid move -> return 1 in $v0
	j verify_move_done
	
verify_move_99:

	li $v0, 2				# if the distance == 99 -> return $v0 == 2

	lbu $t0, 5($s0)				# load the current players turn
	li $t1, 'T'
	beq $t0, $t1, verify_move_99B
	
	li $t0, 'T'				# if current player != 'T' -> then we change current turn to 'T'
	sb $t0, 5($s0)
	j verify_move_done
	
verify_move_99B:				# Change the current turn to bottom players turn

	li $t0, 'B'
	sb $t0, 5($s0)
	
verify_move_done:

	lw $s0, 0($sp)				# restore temp registers from the stack frame
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra, 12($sp)
	
	addi $sp, $sp, 16
	
	jr  $ra					# return $v0
	
#---------------------------------------------------------------------------------------------------------------------------#

execute_move:			# $a0 -> game state, $a1 -> the origin pocket of the move to be executed (1000 instructions roughly)

# Preamble

	addi $sp, $sp, -28
	sw $s0, 0($sp)					# $s0 -> copy of game state base address
	sw $s1, 4($sp)					# $s1 -> copy of starting index
	sw $s2, 8($sp)					# $s2 -> total stones from origin_pocket
	sw $s3, 12($sp)					# $s3 -> flag that indicates special cases 
	sw $s4, 16($sp)					# $s4 -> current row we are in
	sw $s5, 20($sp)					# $s5 -> be the total stones to add to players mancala
	sw $ra, 24($sp)					# Making function calls -> so we're saving $ra
	
	move $s0, $a0					# save a copy of the game state
	move $s1, $a1					# save a copy of the starting index to add to
	and $s5, $0, $0					# initialize stones to add to zero
	
	move $a0, $s0					# game state
	lbu $a1, 5($s0)					# player == 5th byte in game state structure
	move $a2, $s1					# distance == origin
	
	jal get_pocket					# get the number of stones at the origin pocket
	
	move $s2, $v0
			
	move $a0, $s0					# move game state into func arg1
	lbu $a1, 5($s0)					# load current player into arg2
	move $a2, $s1					# load origin pocket into arg3
	and $a3, $0, $0					# we want to empty the pocket 
	
	jal set_pocket

# Setup

	lbu $s4, 5($s0)					# Let $s4 == current row we're in (represented by the player)
	addi $s1, $s1, -1				# decrement starting position by one (don't add stones to origin position)
	
# Body

execute_move_loop:

	beqz $s2, execute_loop_update_player			# if we're out of rocks... then we're done
	
	bltz $s1, execute_add_mancala			# if index == 0 -> then we add to the mancala if player == 'T'
	
	and $s3, $0, $0					# set $s3 == 0 -> the stardard case, we are depositing into a pocket
	
	move $a0, $s0					# load game state
	move $a1, $s4					# load player byte
	move $a2, $s1					# load starting position 
	
	jal get_pocket					# calling get pocket
	
	beqz $v0, execute_move_empty_pocket		# if the pocket we are depositing into is empty -> raise empty pocket flag
	
	j execute_move_set_pocket			# else we just keep going, leave the flag as is
	
execute_move_empty_pocket:
	lbu $t0, 5($s0)					
	bne $t0, $s4, execute_move_set_pocket		# if depositing into empty pocket in opponentes row -> continue
	li $s3, 1					# else -> $s3 -> the "1" flag means that our last deposit was in an empty hole
	
execute_move_set_pocket:

	move $a0, $s0					# load game state
	move $a1, $s4					# load player byte
	move $a2, $s1					# load position
	addi $a3, $v0, 1				# add 1 (1 rock) to the pocket
	
	jal set_pocket					# calling set pocket
	
increment_execute_loop:

	addi $s1, $s1, -1				# decrement index of the next position by 1 (top row -> counter-clockwise)
	addi $s2, $s2, -1				# decrement our total number of rocks
	
	j execute_move_loop				# go back to the loop
	
execute_add_mancala:

	lbu $t0, 5($s0)					# Load the player's turn
	beq $t0, $s4, execute_add_stones		# if current_mancala == player's mancala -> then add a stone
							# else we update the row we are operating on
	j execute_loop_update_row		
	
execute_add_stones:
	
	addi $s5, $s5, 1				# increment stones to add to mancala
	addi $s2, $s2, -1				# decrement total stones by 1
	
	li $s3, 2					# update our flag to "2" -> we just deposited into mancala
	# fall through to update the next row
	
execute_loop_update_row:
	lbu $s1, 3($s0)					# reset $s1 to be the size of the next row
	addi $s1, $s1, -1
	
	li $t0, 'T'
	beq $s4, $t0, execute_loop_bottom		# if we just operated on the top row -> now we're doing the bottom row
	li $s4, 'T'					# else row == 'B' -> next row is top row
	j execute_move_loop				# go back to the loop

execute_loop_bottom:
	li $s4, 'B'					# if current row == 'T' -> next row is bottom row
	j execute_move_loop
	
execute_loop_update_player:
	lbu $t0, 4($s0)					# update the number of moves executed by one
	addi $t0, $t0, 1
	sb $t0, 4($s0)
	
	# Before updating the player -> we need current player who just moved to collect their stones!
	
	move $a0, $s0					# move game state into arg1
	lbu $a1, 5($s0)					# move player into arg2
	move $a2, $s5					# add stones to mancala
	
	jal collect_stones				# calling collect stones -> we want to add all the stones to the mancala
	
	li $t0, 2
	beq $s3, $t0, execute_move_done			# if flag == 2 -> then we don't change the gamestates current player
	
	lbu $t0, 5($s0)					# get the current game player turn
	li $t1, 'T'
	beq $t0, $t1, execute_move_bottom		# if current player turn == 'T' -> then next player move == 'B'
	sb $t1, 5($s0)					# else -> next player is 'T'
	
	j execute_move_done				# now we return
	
execute_move_bottom:
	li $t0, 'B'					# store 'B' as next players turn if 'T' is current players turn
	sb $t0, 5($s0)
	
execute_move_done:
	
	move $v1, $s3					# return our flag in $v1: 0 == default, 1 == steal, 2 == go again
	move $v0, $s5					# return total stones to add in $v0
	addi $t0, $s1, 1	# return index of the pocket we ended at in (sneaky but it'll work I think) -> it's off by 1 here
	
	lw $s0, 0($sp)					# restore the temp registers
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	
	addi $sp, $sp, 28				# increment stack frame
			
	jr $ra						# return, $v0 == stones added, $v1 == indication of special cases
	
#---------------------------------------------------------------------------------------------------------------------------#

steal:			# $a0 -> current state of the game, $a1 -> destination pocket 

# Preamble

	addi $sp, $sp, -20
	sw $s0, 0($sp)					# $s0 -> copy of $a0
	sw $s1, 4($sp)					# $s1 -> copy of $a1
	sw $s2, 8($sp)					# $s2 -> destination row (player)
	sw $s3, 12($sp) 				# $s3 -> total rocks to add to mancala
	sw $ra, 16($sp)					# we'll be making function calls eventually -> preserving $ra now
	
# Settup
	move $s0, $a0					# save a copy of the gamestate sturcture to $s0
	move $s1, $a1					# save a copy of the destination pocket to $s1
	and $s3, $0, $0					# set total rocks to 0
	
	lbu $t0, 5($s0)					# get current player's turn (row to steal from)
	li $t1, 'T'
	beq $t0, $t1, steal_destination_bottom		# if current player == 'T' -> then destination row == 'B'
	li $s2, 'T'					# else -> destination row == 'T'
		
	j steal_body					# continue to the body
	
steal_destination_bottom:
	li $s2, 'B'					# destination row == 'B' -> fall through to function body
	
steal_body:						# alright so $s2 -> is the row of the player who get's to steal

	# move $a0, $a0					# load gamestate -> arg1
	move $a2, $a1					# load distance into -> arg3
	move $a1, $s2					# load player into -> arg2
	
	jal get_pocket					# get stones in that pocket
	
	add $s3, $s3, $v0				# add stones in current pocket to total
	
	move $a0, $s0					# arg1 -> game-state
	move $a1, $s2					# arg2 -> destintation row (player)
	move $a2, $s1					# arg3 -> destination pocket / distance
	and $a3, $0, $0					# arg4 -> 0 
	
	jal set_pocket					# set origin pocket == 0
	
	lbu $t0, 2($s0)					# load board length in the game
	addi $t0, $t0, -1				# subtract 1 -> get the max index of row
	sub $s1, $t0, $s1				# take the differenece between (row_size - origin pocket)
	
	# $s1 -> NOTE $s1 IS NO LONGER A COPY OF $a1 -> $s1 == distance of pocket to steal from
	
	move $a0, $s0					# arg1 -> game-state
	lbu $a1, 5($s0)					# arg2 -> current player (row to steal from)
	move $a2, $s1					# arg3 -> distance to pocket to steal from
	
	jal get_pocket					# get rocks in pocket to steal from
	
	add $s3, $s3, $v0				# add the rocks to steal to the total
	
	move $a0, $s0					# arg1 -> game-state
	lbu $a1, 5($s0)					# arg2 -> current player (row to steal from)
	move $a2, $s1					# arg3 -> distance to pocket we stole from
	and $a3, $0, $0					# arg4 -> 0 
	
	jal set_pocket					# we remove all rocks from hole we stole from
	
	# Now all we have to do is add the stones in $s3 to the previous player's mancala
	# Previous player == $s2
	
	move $a0, $s0					# arg1 -> game-state
	move $a1, $s2					# arg2 -> player's mancala to add to
	move $a2, $s3					# arg3 -> total rocks to add to mancala
	
	jal collect_stones				# collecting the stolen stones into the players mancala
	
steal_done:

	move $v0, $s3					# move stones collected into return value

	lw $s0, 0($sp)					# restoring values from stack frame
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20				# adjusting stack pointer
	
	jr $ra						# $v0 == $s3 -> return rocks collected in $v0
	
#---------------------------------------------------------------------------------------------------------------------------#

check_row:		# $a0 -> current game-state		# roughly 500~ instructions per execution

# Preamble

	addi $sp, $sp, -20		
	sw $s0, 0($sp)					# $s0 -> copy of the game-state base address
	sw $s1, 4($sp)					# $s1 -> starting index for the row size
	sw $s2, 8($sp)					# $s2 -> sum of the rocks in the top row
	sw $s3, 12($sp)					# $s3 -> sum of the rocks in the bottom row
	
	sw $ra, 16($sp)					# save return address
	
# Settup
	
	move $s0, $a0					# saving copy of the game-state
	lbu $s1, 2($s0)					# store row size in $s1
	addi $s1, $s1, -1				# subtract 1 from row size -> (last index in row)
	
	and $s2, $0, $0					# set total top rocks == 0
	and $s3, $0, $0					# set total bottom rocks == 0

# Main loop
check_row_loop:
	
	bltz $s1, check_row_loop_done			# if index < 0 -> then we're done

	move $a0, $s0					# arg1 -> game-state base address
	li $a1, 'T'					# arg2 -> top row
	move $a2, $s1					# arg3 -> index of the pocket to get rocks from
	
	jal get_pocket					# get rocks in top pocket
	
	add $s2, $s2, $v0				# add rocks to running total in top
	
	move $a0, $s0					# arg1 -> game-state base address
	li $a1, 'B'					# arg2 -> bottom row
	move $a2, $s1					# arg3 -> index of the pocket to get rocks from

	jal get_pocket					# get rocks in bottom pocket
	
	add $s3, $s3, $v0				# add rocks to running total in bottom
	
	bnez $s2, check_row_check_bottom		# if $s2 != 0 -> check if $s3 != 0
	
	bnez $s3, check_row_check_top			# if $s3 != 0 -> check if #s2 != 0
		
	j check_row_loop_next				# else continue to iterate summing the stones in the rows

check_row_check_bottom:
	
	bnez $s3, check_row_loop_break			# if $s2 != 0 and $s3 != 0 -> then we can exit early 
	j check_row_loop_next				# else -> proceed to next character
	
check_row_check_top:
	
	bnez $s2, check_row_loop_break			# if $s3 != 0 and $s2 != 0 -> break out of the loop
							# else -> proceed to next character
check_row_loop_next:
	
	addi $s1, $s1, -1				# decrement index
	j check_row_loop				# go to next loop iteration
	
check_row_loop_done:					# if we're here, we need to add the stones to the mancalas

	move $a0, $s0					# arg1 -> game-state
	li $a1, 'T'					# arg2 -> top row
	move $a2, $s2					# arg3 -> stones from top row
	
	jal collect_stones				# collect stones from top row

	move $a0, $s0					# arg1 -> game state
	li $a1, 'B'					# arg2 -> bottom row
	move $a2, $s3					# arg3 -> stones from bottom row
	
	jal collect_stones 				# collect stones from bottom row

	li $v0, 1					# game is over -> load 1 into $v0
	li $t0, 'D'
	sb $t0, 5($s0)					# update the player in game-state to done -> 'D'
	
	j check_row_get_mancala				# next -> we check which mancala has more stones
	
check_row_loop_break:

	li $v0, 0					# if $s2 != 0 and $s3 != 0 -> then we return $v0 == 0
							# fall through to get mancala with more stones in it
check_row_get_mancala:	
	lbu $t0, 0($s0)					# get rocks in bottom mancala
	lbu $t1, 1($s0)					# get rocks in top mancala
	bgt $t0, $t1, check_row_bottom			# if bottom > top -> then return player 1 
							
	bgt $t1, $t0, check_row_top			# else if top > bottom -> return player 2
	
	move $v1, $0					# else, we have a tie game -> return 0
	j check_row_done				# jump to done
	
check_row_top:
	li $v1, 2					# if top > bottom -> return player 2
	j check_row_done				# jump to done
	
check_row_bottom:
	li $v1, 1					# if bottom > top -> return player 1
							# fall through to done
check_row_done:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra			# return; $v0 -> 1 if game is over, 0 otherwise; $v1 -> 1 if top > bottom, 2 if bottom > top, else 0
	
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
	
	bltz $v0, load_moves_done			# if file error -> return $v0 = -1
	move $s0, $v0					# save a copy of the file descriptor to $s0
	
	move $a0, $s0					# arg1 -> file descriptor
	jal load_next_byte				# get the number of columns in the array
	move $s1, $v0					# $s1 = columns

	bltz $v0, load_moves_done			# if there's an error reading from the file -> then return (-1)
	
	move $a0, $s0					# arg1 -> file descriptor
	jal load_next_byte				# get the number of rows in the array
	move $s2, $v0					# $s2 = rows

	move $a0, $s0					# arg1 -> file descripter
	move $a1, $s3					# arg2 -> base address of byte array
	move $a2, $s2					# arg3 -> number of rows
	mul $a3, $s1, $s2				# arg4 -> rows * cols -> (size of moves array)
	
	jal load_moves_helper				# loads the characters into the byte array
	
	move $s1, $v0
	
load_moves_done:

	move $a0, $s0					# CLOSING THE FILE
	li $v0, 16
	syscall
	
	move $v0, $s1					# moving the items into the return register

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20				
	
	jr $ra						# return, $v0 -> total moves in the moves array 
	
#---------------------------------------------------------------------------------------------------------------------------#
	
play_game:	# $a0 -> moves_file, $a1 -> board_file, $a2 -> gamestate struc, $a3 -> moves array, 0($sp) -> num_moves

	move $fp, $sp					# saving copy of stack pointer -> get the last arg easier
	
	addi $sp, $sp, -24
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> temp copy of moves filename
	sw $s1, 8($sp)					# $s1 -> temp copy of board filename
	sw $s2, 12($sp)					# $s2 -> copy of game-state base address
	sw $s3, 16($sp)					# $s3 -> copy of moves-array base address
	sw $s4, 20($sp)					# total valid moves executed
	
	move $s0, $a0					# moves filename
	move $s1, $a1					# board filename
	move $s2, $a2					# gamestate
	move $s3, $a3					# moves array
	move $s4, $0
	
	# First we want to load the game and the moves into the game struc and moves array
	
	move $a0, $s3					# load moves array
	move $a1, $s0					# load moves filename
	
	jal load_moves					# load moves from file into moves array
	
	blez $v0 play_game_invalid_file		# if there's an error loading the moves file -> return (-1, -1)
	
	move $s0, $v0					# $s0 -> total moves in the move array (bad moves, 99's included)
	
	move $a0, $s2					# load gamestate
	move $a1, $s1					# load board filename
	
	jal load_game					# loads the game from the game file into the game-state structure
	
	blez $v0, play_game_invalid_file		# if there's an error loading the board file -> return (-1, -1)

	# Once everything is loaded into memory, we need to set up our loop
	
	lw $s1, 0($fp)					# $s1 -> total moves to execute -> get from frame pointer
	
play_game_loop:
	
	beqz $s0, play_game_loop_done			# if -> reached the end of the moves array -> exit (no more moves)
	beqz $s1, play_game_loop_done			# if -> executed the specified number of moves
	
	# First -> check if the move is valid
	
	move $a0, $s2					# arg1 -> game-state base address
	lbu $a1, 5($s2)					# arg2 -> current player
	lbu $a2, 0($s3)					# arg3 -> origin pocket of next move to execute
	
	jal get_pocket					# get stones in the pocket to execute the next move on
	
	move $a0, $s2					# arg1 -> game-state base address
	lbu $a1, 0($s3)					# arg2 -> next move in moves array
	move $a2, $v0					# arg3 -> distance we'll be going with the stones
	
	li $t0, 99
	beq $a1, $t0, play_game_loop_next		# if next_move == 99 -> go to next move
	
	jal verify_move					# else -> check if the next move is a valid move
	
	li $t0, 1
	bne $v0, $t0, play_game_loop_next		# if the next move isn't valid -> then go to the next move
	
	move $a0, $s2					# arg1 -> game-state base address
	lbu $a1, 0($s3)					# arg2 -> next move in the moves array
	
	jal execute_move				# execute the move
	
	addi $s4, $s4, 1				# if the move executes successfully -> increment total moves
	
	beqz $v1, play_game_loop_next			# if execute_move == 0 -> go to next iteration
	
	li $t1, 1
	beq $v1, $t1, play_game_loop_steal		# if execute_move == 1 -> execute steal
	
	li $t1, 2
	beq $v1, $t1, play_game_loop_next		# if execute_move == 2 -> go to next iteration (case handled in execute move)
	
	j play_game_invalid_file			# execute_move should only return 0, 1, or 2
	
play_game_loop_steal:

	move $a0, $s2					# arg1 -> game-state base address
	move $a1, $t0					# arg2 -> destination pocket of last execute move
	
	jal steal					# make the steal
	
	# ignoring return value (I don't think it's important -> stones should have been added to mancala already)
	
	j play_game_loop_next				# move to the next loop iteration
	
play_game_loop_change_team:				# if execute_move == 2 -> change current player turn
	
	lbu $t0, 5($s2)					# load the current players turn
	li $t1, 'B'
	
	beq $t0, $t1, play_game_loop_change_top		# if current player == 'B' -> then set current player to 'T'
	sb $t1, 5($s2)					# else set current player to 'B'
	
	j play_game_loop_next				# go to next loop iteration
	
play_game_loop_change_top:
	li $t0, 'T'
	sb $t0, 5($s2)					# change current player -> to the top player
	# fall through to next
	
play_game_loop_next:
	
	# Third -> check if the game is over or not, if so we exit the loop, if not, keep going
	
	move $a0, $s2					# arg1 -> game-state base address
	
	jal check_row					# check the rows of the updated game-state after the move
	
	bnez $v0, play_game_loop_done			# if check_row != 0 -> then the game is over

	addi $s3, $s3, 1				# increment base address of moves array by 1 (get next move)
	addi $s0, $s0, -1				# decrement moves remaining in moves array by 1
	addi $s1, $s1, -1				# decrement moves left to execute by 1
	
	move $a0, $s2					# print out the board
	jal print_board
	
	lbu $a0, 5($s2)					# print player
	li $v0, 11
	syscall
	
	li $a0, '\n'
	li $v0, 11
	syscall
	
	j play_game_loop

play_game_loop_done:

	# Now all we have to do is check who won and return the total moves executed
	
	move $a0, $s2					# arg1 -> game-state
	jal check_row					# check the rows for a winner
	
	move $v0, $v1					# move winning player into $v0

	lb $t0, 0($fp)					# get total moves we were allowed to execute
	sub $v1, $t0, $s1				# subtract moves remaining from total moves (to get moves executed)

	j play_game_done
	
play_game_invalid_file:
	li $v0, -1					
	li $v1, -1
	
play_game_done:
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	addi $sp, $sp, 24
	
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#

print_board:						# $a0 -> valid board structure, roughly 250 instructions or so

# Preamble

	addi $sp, $sp, -4
	sw $s0, 0($sp)
	move $s0, $a0					# Save a copy of the game state in $s0
	
# Body
	lbu $a0, 6($s0)					# Print first character of top players mancala
	li $v0, 11
	syscall
	
	lbu $a0, 7($s0)					# Print second character of top players mancala
	li $v0, 11
	syscall 
	
	li $a0, '\n'					# Print a newline
	li $v0, 11
	syscall
	
	lbu $t0, 3($s0)					# Load the number of piles in top players row
	li $t1, 4		
	mul $t0, $t0, $t1				# Multiplies top row piles by 2
	addi $t0, $t0, 8				# Add 8 to it -> result should get us to last two bytes in $s0
	
	add $t0, $s0, $t0				# increment to end of the game structure
	
	lbu $a0, 0($t0)					# print second to last character in thee game string
	li $v0, 11
	syscall
	
	lbu $a0, 1($t0)					# print last character in the game string
	li $v0, 11
	syscall
		
	li $a0, '\n'					# print a newline character
	li $v0, 11
	syscall
	
	lbu $t0, 3($s0)					# get the size of the row
	li $t1, 2					
	
	mul $t0, $t0, $t1				# multiply $t0 by 2 -> marking end of the top row
	mul $t1, $t0, $t1				# multiply $t1 by 2 -> marking end of bottom row
	addi $s0, $s0, 8				# increment base address up to byte 8
	
print_board_loop:
	beqz $t0, print_board_newline			# if we've printed all of the top row, then print a newline character
	beqz $t1, print_board_done			# if we've printed both rows, then stop printing
	
	lbu $a0, 0($s0)					# print the next character
	li $v0, 11
	syscall
	
	j print_board_nextchar
	
print_board_newline:

	li $a0, '\n'					# prints a newline character
	li $v0, 11
	syscall
	
	addi $t0, $t0, -1
	j print_board_loop
	
print_board_nextchar:

	addi $s0, $s0, 1				# increments the counter variables accordingly
	addi $t0, $t0, -1
	addi $t1, $t1, -1
	j print_board_loop
	
print_board_done:
	
	li $a0, '\n'					# prints an extra newline character after the last line
	li $v0, 11
	syscall
	
	lw $s0, 0($sp)
	addi $sp, $sp, 4

	jr $ra
	
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
	
							# if there's an error getting descriptor -> return -1
	bltz $v0, write_board_file_error		# else -> continue
							
	move $s1, $v0					# move file descriptor to $s1
	
	# Write the top mancala to the file
	
	move $a0, $s1					# arg1 -> file descriptor
	lbu $a1, 6($s0)					# arg2 -> ten's place digit of top mancala's total
	jal write_board_write_char			# write ten's place digit of top mancala
	
	bltz $v0, write_board_file_error		# if error occurs while writing to file -> return (-1)
	
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
# HELPER METHODS START HERE!!!	
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
	

load_next_byte:	# $a0 -> the initial file pointer to the top of the mancala		# instructions < 50 roughly

	addi $sp, $sp, -12				# allocating stack space
	sw $ra, 0($sp)			
	sw $s0, 4($sp)					# $s0 -> copy of $a0 (file pointer)
	sw $s1, 8($sp)					#
	
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
	
	bltz $v0, load_next_byte_error			# if there's an reading the file ->  return -1
	
	# 0($sp) == 1's place or '\n' and 4($sp) == one's place or ten's place
	
	li $t0, '\n'
	lbu $t1, 0($sp)
	beq $t0, $t1, load_next_byte_single		# if 0($sp) == '\n' -> then we're dealiing with 4($sp) == total stones
	
	lbu $s1, 4($sp)					# load ten's place digit
	addi $s1, $s1, -48				# get integer value of ten's place
	li $t0, 10
	mul $s1, $s1, $t0				# multiply result by 10
	lbu $t0, 0($sp)
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

	lbu $v0, 4($sp)					# get the digit on the stack
	addi $v0, $v0, -48				# subtract 48 to get the decimal / integer value of the character

	# fall through to done

load_next_byte_error:
	li $v0, -1				# if there's an error reading to a file -> then return -1
	li $v1, -1
	
load_next_byte_done:	# $v0 -> the stones in the top, $v1 -> the new file pointer
	
	addi $sp, $sp, 8				# deallocate stack space used for reading characters from the file
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	addi $sp, $sp, 12
	jr $ra						# return, $v0 -> stones in top mancala $v1 -> new file pointer?
	
#---------------------------------------------------------------------------------------------------------------------------#

load_game_rows:		# $a0 -> the file descriptor, $a1 -> the current game-state structure

	addi $sp, $sp, -28				# allocating stack space
	sw $ra, 0($sp)
	sw $s0, 4($sp)					# $s0 -> running total of stones found
	sw $s1, 8($sp)					# $s1 -> running total of pockets
	
	sw $s2, 12($sp)					# $s2 -> temp sum of pocket
	sw $s3, 16($sp)					# $s3 -> temp base address of game-state
			
	sw $s4, 20($sp)					# $s4 -> copy of file descriptor
	sw $s5, 24($sp)					# $s5 -> copy of game-state structure

# Setup

	addi $sp, $sp, -4				# allocate stack space for the first character
	move $s0, $0					# total_stones = 0
	move $s1, $0					# total_pockets = 0
	
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

load_moves_helper:		# $a0 -> file descripter, $a1 -> byte array, $a2 -> row size, $a3 -> array_length

	addi $sp, $sp, -32	
	sw $ra, 0($sp)					
	sw $s0, 4($sp)					# $s0 -> copy of file descriptor		
	sw $s1, 8($sp)					# $s1 -> copy of byte array
	sw $s2, 12($sp)					# $s2 -> copy of the row size
	sw $s3, 16($sp)					# $s3 -> temp value of the row size
	sw $s4, 20($sp)					# $s4 -> rows encountered
	sw $s5, 24($sp)					# $s5 -> items added to the byte array
	sw $s6, 28($sp)					# $s6 -> copy of array_length
	
	move $s0, $a0					# save copy of file descriptor
	move $s1, $a1					# save copy of base address of byte array
	move $s2, $a2					# save copy of the row size
	move $s6, $a3					# save copy of array_length
	addi $s6, $s6 -1				# decrement by 1 -> (row * col - 1) -> last index in array
	
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
#	bge $s4, $s6, load_moves_helper_done 		# if we've seen (size - 1) element -> exit
	
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
	addi $v0, $v0, -1				# subtract 1 from total elements -> for 99 at the end of the array
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	lw $s5, 24($sp)
	lw $s6, 28($sp)
	addi $sp, $sp, 32
	
	jr $ra

#---------------------------------------------------------------------------------------------------------------------------#

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
  	
#---------------------------------------------------------------------------------------------------------------------------#

read_character:		# $a0 -> file descriptor of the file to read character from
 	
 	addi $sp, $sp, -4

 #	move $a0, $a0					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	beqz $v0, read_character_endfile		# if $v0 == end of file -> return -1
	
	lbu $v0, 0($sp)					# load unsigned character value
	addi $sp, $sp, 4				# deallocate stack space
	jr $ra
	
read_character_endfile:
	li $v0, -1
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#
 	
 	
	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
