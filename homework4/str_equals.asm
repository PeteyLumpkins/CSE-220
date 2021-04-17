###################################################################################################################################
	
str_equals:		# $a0 -> the first string, $a1 -> the second string

# No preamble required -> I don't think I need to save any registers

	lbu $t0, 0($a0)					# $t0 -> character from the first string
	lbu $t1, 0($a1)					# $t1 -> character from the second string
	
	bne $t0, $t1, str_equals_false			# if ($t0 != $t1) -> return false
	
	beqz $t0, str_equals_true			# if ($t0 == $t1 && $t0 == '\0') -> return true
	
	addi $a0, $a0, 1				# increment base address of str1
	addi $a1, $a1, 1				# increment base address of str2
	j str_equals

str_equals_true:
	li $v0, 1					# if 
	j str_equals_done
	
str_equals_false:
	move $v0, $0
	# fall through to done
	
str_equals_done:

# No postamble required -> didn't need to save any registers
	jr $ra						# $v0 == 1 -> if strings are equal, $v0 == 0 if not equal
	
###################################################################################################################################
