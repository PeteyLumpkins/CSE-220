###################################################################################################################################

str_len:		# $a0 -> the base address of the string 

# Preamble
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $0					# $s0 -> number of characters in the string
# Body

str_len_loop:
	lbu $t0, 0($a0)					# load a byte in the string
	beqz $t0, str_len_done				# if next_char == '\n' -> then we're done
	
	addi $s0, $s0, 1				# else -> increment total chars
	addi $a0, $a0, 1				# else -> increment base address of the string
	j str_len_loop

str_len_done:
	move $v0, $s0					# return -> $s0 -> total characters in the string
	
# Postamble
	
	lw $s0, 0($sp)					
	addi $sp, $sp, 4
	jr $ra						# $v0 -> the length of the string
	
###################################################################################################################################
