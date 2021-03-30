# Peter Walsh
# ptwalsh
# 112599920

############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################

.text

load_game:						# $a0 -> starting address of game state structure $a1 -> game filename
	
# Preamble

	addi $sp, $sp, -24				# Allocating stack space
	sw $ra, 0($sp)					# Saving return address
	sw $s0, 4($sp)					# $s0 -> holds the base address of game structure
	sw $s1, 8($sp)					# $s1 -> holds the file descriptor
	sw $s2, 12($sp)					
	sw $s3, 16($sp)					# $s3 -> holds the amount we have to add back to our stack
	
	sw $s4, 20($sp)					# $s4 -> is going to be our running count of the # of rocks we have
	
	move $s0, $a0					# We need to hang onto the value in $a0 -> storing a copy in $s0
	
# Body

	move $a0, $a1					# loading function arguement with base address of file to open
	li $a1, 0					# setting flag to read only access
	li $v0, 13				
	syscall
	
	li $t0, -1
	beq $v0, $t0, invalid_input_file		# if file descriptor is negative -> return (-1, -1)
	
# main loop setup

	move $s1, $v0					# save file descriptor in $s1
	li $s2, 0					# $s2 -> # of newlines encountered
	
read_loop:
	addi $sp, $sp, -4				# allocate stack space for buffer...?

	move $a0, $s1					# move file descriptor into $a0
	move $a1, $sp					# stack is input buffer for next character
	li $a2, 1					# we want to just read 1 character
	li $v0, 14					# load system call 14
	syscall
	
	beqz $v0, read_loop_done			# if we've hit the end of the file -> the loop is done
	
	lw $t0, 0($sp)
	li $t1, '\n'
	beq $t0, $t1, next_line				# if we find a newline character -> increment # of newlines found
	j read_next_character				# else we read the next character
	
next_line:
	addi $s2, $s2, 1				# incremnent # of new lines found
	li $t0, 3
	beq $s2, $t0, save_frame_pointer		# if we have found our third newline -> save the frame pointer
	j read_next_character				# else read the next character
	
save_frame_pointer:
	move $fp, $sp					# save frame pointer (location of # of rows and the start of row 1
							# move to the next character
read_next_character:
	j read_loop					# push the next character in the file onto the stack
	
read_loop_done:						

# At this point, everything that has been read in from the file is on the stack frame. The top of the stack
# points to the end of file maker, and $fp marks the location of the start of the top players row.

	addi $fp, $fp, -4				# increment frame pointer to top players first hole
	addi $sp, $sp, 8				# have faith in me, I'm doing this for a reason
	
	li $s2, 1					# if $s2 == 1 -> tens place digit else -> ones place digit
	
	addi $t0, $s0, 8				# increment base address of game state by 8
	
process_loop:	
	
	lbu $t1, 0($fp)					# load next character
	li $t2, '\n'
	beq $t1, $t2, process_next_character		# if next_char -> '\n' then skip it
	
	beqz $t1, process_loop_done			# if next_char -> '\0' then we're done
	
	sb $t1, 0($t0)					# store rocks in a pile to the game state
	
	addi $t1, $t1, -48				# get the integer value of the character we're working with
	
	li $t2, 1
	beq $t2, $s2, add_tens_place			# if $s2 == 1, then we add integer value of character * 10 to our total rocks
	
	add $s4, $s4, $t1				# else it's just a one's place digit, add directly to the total
	
	li $s2, 1					# if this digit is in one's place, next digit will be in tens place
	
	j process_next_character
	
add_tens_place:

	li $t2, 10
	mul $t1, $t1, $t2				# if ten's place digit -> multiply integer value of character by 10 then
	add $s4, $s4, $t1				# we add it to our total # of rocks
	
	li $s2, 0					# if this digit is in the tens place -> next digit will be in one's place
		
	j process_next_character
					
process_next_character:
	
	addi $fp, $fp, -4				# increment to the next byte in the stack
	addi $sp, $sp, 4				# as we move frame pointer up, I want to move stack pointer down
	addi $t0, $t0, 1				# increment to the next byte in game state
	j process_loop
	
process_loop_done:		


read_row_size:						# now we want to read the row size from the stack and add it to the game state
	and $s2, $s2, $0				# set $s2 == 0

	lw $t0, 0($sp)					# One's place should be on top of the stack
	lw $t1, 4($sp)					# If ten's place -> should be right below 
	
	addi $t0, $t0, -48
	add $s2, $s2, $t0				# add integer value of $t0 to our result
	
	li $t2, '\n'
	beq $t1, $t2, row_size_done			# if $t1 == '\n' then we're dealing with a single char
	
	li $t0, 10
	addi $t1, $t1, -48				# get integer value of $t1
	mul $t1, $t1, $t0				# multiply $t1 by 10 
	add $s2, $s2, $t1				# add $t1 to our result
	
	addi $sp, $sp, 4				# adjust stack pointer (we have an extra character before start of next item)
	
row_size_done:
	
	sb $s2, 2($s0)					# update the top rows with $s2
	sb $s2, 3($s0)					# update the bottom rows with $s2
	
	addi $sp, $sp, 8				# adjust stack pointer -> should skip next newline character
	
read_stones_bottom:

	and $s2, $s2, $0				# reset values of $s2 and $s3 to zero
	and $s3, $s3, $0

	lw $t0, 0($sp)					# One's place should be on top of the stack
	lw $t1, 4($sp)					# If ten's place -> should be right below 
	
	addi $t0, $t0, -48
	add $s2, $s2, $t0				# add integer value of $t0 to our result
	
	li $t2, '\n'
	beq $t1, $t2, read_bottom_done			# if $t1 == '\n' then we're dealing with a single char
	
	move $s3, $t1
	li $t0, 10
	
	addi $t1, $t1, -48				# get integer value of $t1
	mul $t1, $t1, $t0				# multiply $t1 by 10 
	add $s2, $s2, $t1				# add $t1 to our result
	
	addi $sp, $sp, 4				# adjust stack pointer (we have an extra character before start of next item)

read_bottom_done:
	
	sb $s3, 6($s0)					# saving the bytes to the game state structure
	sb $s2, 0($s0)
	
	addi $sp, $sp, 12
	
	j load_game_done
	
invalid_input_file:
	
	li $v0, -1
	li $v1, -1

load_game_done:
# Postamble
	
	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	lw $s4, 20($sp)
	
	addi $sp, $sp, 24
	
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

	addi $sp, $sp, -12			# save registers to the stack frame
	sw $s0, 0($sp)				# Let $s0 == copy of game_state ($a0)
	sw $s1, 4($sp)				# Let $s1 == copy of the distance ($a2) 
	sw $s2, 8($sp)				# Let $s2 == copy of origin_pocket ($a1)
	sw $ra, 12($sp)				# making function calls -> so we save $ra at the top
	
# Body

	blez $a2, verify_move_invalid2		# if distance <= 0 then return $v0 == -2
	
	li $t0, 99				# if distancee == 99 -> thenn return $v0 == 2
	beq $a2, $t0, verify_move_99
	
	move $s0, $a0				# Save game state
	move $s1, $a2				# Save the distance
	move $s2, $a1				# Save origin pocket
	
	# move $a0, $s0				# load gamestate into arg1
	lbu $a1, 5($s0)				# load current players turn into arg2
	move $a2, $s2				# load origin_pocket into $a2
	
	jal get_pocket				# getting number of stones in the origin_pocket
	
	beqz $v0, verify_move_done		# there are no stones in the origin_pocket -> so we can just return
	
	li $t0, -1
	beq $v0, $t0, verify_move_invalid1	# if get_pocket returns -1 -> then the move is invalid
	
	bne $v0, $s1, verify_move_invalid2	# if the distance != number stones in origin pocket -> invalid move
	
	j verify_move_valid			# otherwise -> the move is valid, or should be that is...
	
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
	
	addi $sp, $sp, 8
	
	jr  $ra					# return $v0
	
#---------------------------------------------------------------------------------------------------------------------------#

execute_move:

# Preamble

	addi $sp, $sp, -20
	sw $s0, 0($sp)					# using $s0, $s1, $s2 -> for copies of arguements
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s4, 12($sp)
	sw $ra, 16($sp)					# Making function calls -> so we're saving $ra
	
	move $s0, $a0					# save a copy of the game state
	move $s1, $a1					# save a copy of the starting index to add to
	
	move $a0, $s0					# game state
	lbu $a1, 5($s0)					# player == 5th byte in game state structure
	move $a2, $s1					# distance == origin
	
	jal get_pocket					# get the number of stones at the origin pocket
	
	move $s2, $v0

# Setup

	lbu $s4, 5($s0)					# Let $s4 == current row we're in (represented by the player)
	addi $s1, $s1, -1				# decrement starting position by one (don't add stones to origin position)
	
# Body

execute_move_loop:

	beqz $s2, execute_loop_done			# if we're out of rocks... then we're done
	
	bltz $s1, execute_add_mancala			# if index == 0 -> then we add to the mancala if player == 'T'
	
	move $a0, $s0					# load game state
	move $a1, $s4					# load player byte
	move $a2, $s1					# load starting position 
	
	jal get_pocket					# calling get pocket
	
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
	
	lbu $s1, 3($s0)					# reset $s1 to be the size of the next row
	move $a0, $s0					# move game state into arg1
	move $a1, $s4					# move player into arg2
	li $a2, 1					# add one stone to mancala
	
	jal collect_stones				# calling collect stones
	addi $s2, $s2, -1				# decrement total stones by 1
	
	# fall through to update the next row
	
execute_loop_update_row:
	lbu $s1, 3($s0)					# reset $s1 to be the size of the next row
	
	li $t0, 'T'
	beq $s4, $t0, execute_loop_bottom		# if we just operated on the top row -> now we're doing the bottom row
	li $s4, 'T'					# else row == 'B' -> next row is top row
	j execute_move_loop				# go back to the loop

execute_loop_bottom:
	li $s4, 'B'					# if current row == 'T' -> next row is bottom row
	j execute_move_loop
	
execute_loop_done:
	
	move $v0, $s2					# return remaining rocks in $v0
	lbu $v1, 2($s0)					# load the number of rows into $v1
	addi $v1, $v1, -1				# decrement by 1 -> gives us last index in the top row of the board
	
	lw $s0, 0($sp)					# restore the temp registers
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s4, 12($sp)
	lw $ra,  16($sp)
	
	addi $sp, $sp, 20				# increment stack frame
			
	jr $ra						# return, $v0 == remaining rocks, $v1 == starting index of bottom row
	
#---------------------------------------------------------------------------------------------------------------------------#

steal:
	jr $ra
check_row:
	jr $ra
load_moves:
	jr $ra
play_game:
	jr  $ra
	
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
	
write_board:
	jr $ra
	
#---------------------------------------------------------------------------------------------------------------------------#

add_to_top_row:	# $a0 == game_state, $a1 == starting position, $a2 == number of rocks left

# Preamble

	addi $sp, $sp, -16
	sw $s0, 0($sp)					# using $s0, $s1, $s2 -> for copies of arguements
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $ra, 12($sp)					# Making function calls -> so we're saving $ra
	
	move $s0, $a0					# save a copy of the game state
	move $s1, $a1					# save a copy of the starting index to add to
	move $s2, $a2					# save a copy of the number of rocks left to add 

# Body

add_to_top_loop:

	beqz $s2, add_to_top_done			# if we're out of rocks... then we're done
	
	beqz $s1, add_to_top_mancala			# if index == 0 -> then we add to the mancala if player == 'T'
	
	move $a0, $s0					# load game state
	lbu $a1, 5($s0)					# load player byte
	move $a2, $s1					# load starting position 
	
	jal get_pocket					# calling get pocket
	
	move $a0, $s0					# load game state
	lbu $a1, 5($s0)					# load player byte
	move $a2, $s1					# load position
	addi $a3, $v0, 1				# add 1 (1 rock) to the pocket
	
	jal set_pocket					# calling set pocket
	
increment_top_loop:

	addi $s1, $s1, -1				# decrement index of the next position by 1 (top row -> counter-clockwise)
	addi $s2, $s2, -1				# decrement our total number of rocks
	
	j add_to_top_loop				# go back to the loop
	
add_to_top_mancala:

	move $a0, $s0
	lbu $a1, 5($s0)
	li $a2, 1
	
	jal collect_stones				# if we have the right player -> we add 1 to the top mancala
							# else -> we just return 
	# v0 -> not really relevant here I don't think
	
add_to_top_done:
	
	move $v0, $s2					# return remaining rocks in $v0
	lbu $v1, 2($s0)					# load the number of rows into $v1
	addi $v1, $v1, -1				# decrement by 1 -> gives us last index in the top row of the board
	
	lw $s0, 0($sp)					# restore the temp registers
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $ra,  12($sp)
	
	addi $sp, $sp, 16				# increment stack frame
			
	jr $ra						# return, $v0 == remaining rocks, $v1 == starting index of bottom row

#---------------------------------------------------------------------------------------------------------------------------#
	



	
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
############################ DO NOT CREATE A .data SECTION ############################
