#---------------------------------------------------------------------------------------------------------------------------#

check_row:		# $a0 -> current game-state

# Preamble

	addi $sp, $sp, -20		
	sw $s0, 0($sp)			# $s0 -> copy of the game-state base address
	sw $s1, 4($sp)			# $s1 -> starting index for the row size
	sw $s2, 8($sp)			# $s2 -> sum of the rocks in the top row
	sw $s3, 12($sp)			# $s3 -> sum of the rocks in the bottom row
	
	sw $ra, 16($sp)			# save return address
	
# Settup
	
	move $s0, $a0			# saving copy of the game-state
	lbu $s1, 2($s0)			# store row size in $s1
	addi $s1, $s1, -1		# subtract 1 from row size -> (last index in row)
	
	and $s2, $0, $0			# set total top rocks == 0
	and $s3, $0, $0			# set total bottom rocks == 0

# Main loop
check_row_loop:
	
	bltz $s1, check_row_loop_done	# if index < 0 -> then we're done

	move $a0, $s0			# arg1 -> game-state base address
	li $a1, 'T'			# arg2 -> top row
	move $a2, $s1			# arg3 -> index of the pocket to get rocks from
	
	jal get_pocket			# get rocks in top pocket
	
	add $s2, $s2, $v0		# add rocks to running total in top
	
	move $a0, $s0			# arg1 -> game-state base address
	li $a1, 'B'			# arg2 -> bottom row
	move $a2, $s1			# arg3 -> index of the pocket to get rocks from

	jal get_pocket			# get rocks in bottom pocket
	
	add $s3, $s3, $v0		# add rocks to running total in bottom
	
	bnez $s2, check_row_check	# if $s2 != 0 -> check if $s3 != 0
		
	j check_row_loop_next		# else continue to iterate summing the stones in the rows

check_row_check:
	
	bnez $s3, check_row_loop_break	# if $s3 != 0 and $s3 != 0 -> then we can exit early 
					# else -> proceed to next character
check_row_loop_next:
	
	addi $s1, $s1, -1		# decrement index
	j check_row_loop		# go to next loop iteration
	
check_row_loop_done:			# if we're here, we need to add the stones to the mancalas

	move $a0, $s0			# arg1 -> game-state
	li $a1, 'T'			# arg2 -> top row
	move $a2, $s2			# arg3 -> stones from top row
	
	jal collect_stones		# collect stones from top row

	move $a0, $s0			# arg1 -> game state
	li $a1, 'B'			# arg2 -> bottom row
	move $a2, $s3			# arg3 -> stones from bottom row
	
	jal collect_stones 		# collect stones from bottom row

	li $v0, 1			# game is over -> load 1 into $v0
	j check_row_get_mancala		# next -> we check which mancala has more stones
	
check_row_loop_break:

	li $v0, 0			# if $s2 != 0 and $s3 != 0 -> then we return $v0 == 0
					# fall through to get mancala with more stones in it
check_row_get_mancala:	
	lbu $t0, 0($s0)			# get rocks in bottom mancala
	lbu $t1, 1($s0)			# get rocks in top mancala
	bgt $t0, $t1, check_row_bottom	# if bottom > top -> then return player 1 
					# else if bottom <= top -> then return player 2
	li $v1, 2
	j check_row_done
	
check_row_bottom:
	li $v1, 1			# if bottom > top -> return player 1
					# fall through to done
check_row_done:

	lw $s0, 0($sp)
	lw $s1, 4($sp)
	lw $s2, 8($sp)
	lw $s3, 12($sp)
	lw $ra, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra				# return; $v0 -> 1 if game is over, 0 otherwise; $v1 -> 1 if top > bottom, 2 otherwise
	
#---------------------------------------------------------------------------------------------------------------------------#
