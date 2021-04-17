###################################################################################################################################

is_person_name_exists:		# $a0 -> base address of the network structure, $a1 -> base address of the name

# Preamble

	addi $sp, $sp, -20
	sw $ra, 0($sp)					# probably going to check name equality -> save return address now
	sw $s0, 4($sp)					# $s0 -> copy of base addr of network structure
	sw $s1, 8($sp)					# $s1 -> copy of base addr of name
	sw $s2, 12($sp)					# $s2 -> size of a node in the network
	sw $s3, 16($sp)					# $s3 -> next node in the network
	
	move $s0, $a0					# save copy of network
	move $s1, $a1					# save copy of string-name
	
# Body	
	
	lw $s2, 8($s0)					# load size of a node in the network
	
	move $a0, $a1					# arg1 -> base addr of name
	jal str_len
	bge $v0, $s2, person_name_not_exists		# if name_length >= node_size -> then the name doesn't exist
	
	addi $s3, $s0, 36				# increment base address by 36 -> get the address of first node
	
person_name_exists_loop:
	
	move $a0, $s0					# arg1 -> base address of network
	move $a1, $s3					# arg2 -> base address of next node
	jal is_person_exists				
	
	beqz $v0, person_name_not_exists		# if the person does not exist in the network -> then we're done
	
	move $a0, $s3					# arg1 -> base address of name in the network
	move $a1, $s1					# arg2 -> the name we want to check
	jal str_equals					
	
	bnez $v0, person_name_exists			# if $v0 != 0 -> then the person must exist
	
	add $s3, $s3, $s2				# (next_name) += node_size
	j person_name_exists_loop			# goto next iteration

person_name_not_exists:
	li $v0, 0
	j person_name_exists_done			
	
person_name_exists:
	li $v0, 1
	move $v1, $s3					# return reference to the person in the network if found
	# fall through to done
	
person_name_exists_done:

# Postamble

	lw $ra, 0($sp)
	lw $s0, 4($sp)
	lw $s1, 8($sp)
	lw $s2, 12($sp)
	lw $s3, 16($sp)
	addi $sp, $sp, 20
	
	jr $ra			# $v0 == 0 -> if name doesn't exist, $v0 == 1 and $v1 == address of person if name exists
	
###################################################################################################################################
