###################################################################################################################################
	
str_cpy:		# $a0 -> base address of the source string, $a1 -> base address of destination string

# Preamble
	
	addi $sp, $sp, -4
	sw $s0, 0($sp)
	
	move $s0, $0					# $s0 -> number of copied characters
	
# Body

str_cpy_loop:
	
	lbu $t0, 0($a0)					# load character from source string
	beqz $t0, str_cpy_done				# if next_char == '\0' -> then we're done with the loop
	
	sb $t0, 0($a1)					# else -> store the byte in the destination string
	addi $s0, $s0, 1				# increment chars seen
	addi $a0, $a0, 1				# increment base address of src string
	addi $a1, $a1, 1				# increment base address of dest string
	j str_cpy_loop					# go to next character
	
str_cpy_done:

# Postamble

	move $v0, $s0					# return -> $s0 -> chars copied
	sb $0, 0($a1)					# store null terminator string at the end of dest string
	
	lw $s0, 0($sp)			
	addi $sp, $sp, 4
	jr $ra
	
###################################################################################################################################
