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
	beq $a1, $t0, play_game_loop_next		# if next_move == 99 -> change the team
	
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
