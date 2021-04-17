###################################################################################################################################

get_person:		# $a0 -> the base address of the network structure, $a1 -> base address of the name to search for

# Preamble

	addi $sp, $sp, -4
	sw $ra, 0($sp)

# Body
	jal is_person_name_exists			# if name exists -> $v1 should contain reference to name in the network
	
	bnez $v0, get_person_found			# if $v0 != 0 -> then we found the person and $v1 == base address of person
	li $v0, 0
	j get_person_done				# else $v0 == 0 -> then person was not found, return $v0 == 0
	
get_person_found:
	move $v0, $v1					# if person is found -> return $v0 == base address of person in network
	# fall through to done
	
get_person_done:
# Postamble	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
###################################################################################################################################
