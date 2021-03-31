#---------------------------------------------------------------------------------------------------------------------------#

execute_move:			# $a0 -> game state, $a1 -> the origin pocket of the move to be executed (983 instructions roughly)

# Preamble

	addi $sp, $sp, -28
	sw $s0, 0($sp)					# using $s0, $s1, $s2 -> for copies of arguements
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)					# let $s3 -> be our flag -> indicates special cases and things
	sw $s4, 16($sp)
	sw $s5, 20($sp)					# let $s5 -> be the total stones to add to players mancala
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
	li $s3, 1					# $s3 -> the "1" flag means that our last deposit was in an empty hole
	
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

	move $a0, $s0					# move game state into arg1
	move $a1, $s4					# move player into arg2
	move $a2, $s5					# add stones to mancala
	
	jal collect_stones				# calling collect stones -> we want to add all the stones to the mancala
	
	move $v1, $s3					# return our flag in $v1: 0 == default, 1 == steal, 2 == go again
	move $v0, $s5					# return total stones to add in $v0
	
	lw $s0, 0($sp)					# restore the temp registers
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $s4, 16($sp)
	lw $s5, 20($sp)
	lw $ra, 24($sp)
	
	addi $sp, $sp, 28				# increment stack frame
			
	jr $ra						# return, $v0 == remaining rocks, $v1 == starting index of bottom row
	
#---------------------------------------------------------------------------------------------------------------------------#
