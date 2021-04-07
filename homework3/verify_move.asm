#---------------------------------------------------------------------------------------------------------------------------#

verify_move:		# let $a0 == current game state, $a1 == origin_pocket of the move $a2 == distance of the move

# Preamble

	addi $sp, $sp, -16			# save registers to the stack frame
	sw $s0, 0($sp)				# Let $s0 == copy of game_state ($a0)
	sw $s1, 4($sp)				# Let $s1 == copy of the distance ($a2) 
	sw $s2, 8($sp)				# Let $s2 == copy of origin_pocket ($a1)
	sw $ra, 12($sp)				# making function calls -> so we save $ra at the top
	
# Body

	blez $a2, verify_move_invalid2		# if distance <= 0 then return $v0 == -2
	
	li $t0, 99				# if distance == 99 -> thenn return $v0 == 2
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
	
	addi $sp, $sp, 16
	
	jr  $ra					# return $v0
	
#---------------------------------------------------------------------------------------------------------------------------#
