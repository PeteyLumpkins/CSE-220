#---------------------------------------------------------------------------------------------------------------------------#

steal:			# $a0 -> take the current state of the game, $a1 -> take the destination pocket 

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
